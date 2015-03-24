require "pco/url/version"
require "uri"
require "URLcrypt"

module PCO
  class URL
    class << self
      def decrypt_query_params(string)
        URLcrypt.decrypt(string)
      end

      def parse(string)
        if uri = URI.parse(string)
          app_name = uri.host.match(/(\w+)(-staging)?/)[1]

          if uri.query
            params = Hash[uri.query.to_s.split("&").map { |p| p.split("=") }]

            if params["_e"]
              decrypted_params_string = decrypt_query_params(params.delete("_e"))
              decrypted_params = Hash[decrypted_params_string.split("&").map { |p| p.split("=") }]
              params = params.merge(decrypted_params)
            end

            uri.query = URI.encode(params.map{|k,v| "#{k}=#{v}"}.join("&"))
          end

          new(app_name: app_name, path: uri.path, query: uri.query)
        else
          raise InvalidPCOURLString, "Unrecognized PCO::URL url string"
        end
      end

      def method_missing(method_name, *args)
        path = args.map { |p| p.sub(/\A\/+/, "").sub(/\/+\Z/, "") }.join("/")
        new(app_name: method_name, path: path).to_s
      end
    end

    attr_reader :app_name
    attr_reader :path
    attr_reader :query

    def initialize(app_name:, path: nil, query: nil, encrypt_query_params: false)
      @app_name       = app_name.to_s.gsub("_", "-")
      @path           = path

      if query
        @query = encrypt_query_params ? "_e=#{URLcrypt.encrypt(query)}" : query
      end
    end

    def scheme
      # Try "CHECK_INS_URL" then url_for_app("check-ins")
      return env_overridden_hostname.split("://")[0] if env_overridden_hostname

      case env
      when "production", "staging"
        "https"
      else
        "http"
      end
    end

    def hostname
      # Try "CHECK_INS_URL" then url_for_app("check-ins")
      return env_overridden_hostname.split("://")[1] if env_overridden_hostname

      case env
      when "production"
        "#{@app_name}.planningcenteronline.com"
      when "staging"
        "#{@app_name}-staging.planningcenteronline.com"
      when "development"
        "#{@app_name}.pco.dev"
      when "test"
        "#{@app_name}.pco.test"
      end
    end

    def uri
      query = @query ? "?#{@query}" : nil
      url_string = "#{scheme}://#{hostname}/#{@path}#{query}".sub(/(\/)+$/,'')
      URI(url_string)
    end

    def to_s
      uri.to_s
    end

    private

    def env
      ENV["DEPLOY_ENV"] || Rails.env
    end

    def env_overridden_hostname
      env_var = @app_name.to_s.upcase + "_URL"
      ENV[env_var]
    end
  end

  class InvalidPCOURLString < StandardError; end
end
