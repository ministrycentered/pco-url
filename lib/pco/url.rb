require_relative "url/version"
require_relative "url/avatars"
require_relative "url/church_center"
require_relative "url/get"
require_relative "url/encryption"
require "uri"

module PCO
  class URL
    class << self
      def decrypt_query_params(string)
        Encryption.decrypt(string)
      end

      def parse(string)
        if (uri = URI.parse(string))
          app_name = uri.host.match(/(\w+)(-staging)?/)[1]

          if uri.query
            if (encrypted_part = encrypted_query_string(uri.query))
              uri.query.sub!("_e=#{encrypted_part}", decrypt_query_params(encrypted_part))
            end
          end

          new(app_name: app_name, path: uri.path, query: uri.query)
        else
          fail InvalidPCOURLString, "Unrecognized PCO::URL url string"
        end
      end

      def method_missing(method_name, *args)
        path = args.map { |p| p.sub(%r{\A/+}, "").sub(%r{/+\Z}, "") }.join("/")
        case method_name
        when :avatars
          PCO::URL::Avatars.new(path: path).to_s
        when :church_center
          PCO::URL::ChurchCenter.new(path: path).to_s
        when :get
          PCO::URL::Get.new(path: path).to_s
        else
          new(app_name: method_name, path: path).to_s
        end
      end

      private

      def encrypted_query_string(query_params)
        Regexp.last_match(:param) if query_params =~ encrypted_params_regex
      end

      def encrypted_params_regex
        /\b_e=(?<param>[^\&]*)/
      end
    end

    attr_reader :app_name
    attr_reader :path
    attr_reader :query

    def initialize(app_name:, path: nil, query: nil, encrypt_query_params: false, domain: nil)
      @app_name = app_name.to_s.tr("_", "-")
      @path     = path
      @domain   = domain

      @path = @path[1..-1] if @path && @path[0] == "/"

      if query
        @query = encrypt_query_params ? "_e=#{Encryption.encrypt(query)}" : query
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

    def domain
      return @domain if @domain

      case env
      when "production", "staging"
        "planningcenteronline.com"
      when "development", "test"
        "pco.test"
      end
    end

    def hostname
      # Try "CHECK_INS_URL" then url_for_app("check-ins")
      return env_overridden_hostname.split("://")[1] if env_overridden_hostname

      case env
      when "staging"
        "#{app_name}-staging.#{domain}"
      else
        "#{app_name}.#{domain}"
      end
    end

    def uri
      q = query ? "?#{query}" : nil
      url_string = "#{scheme}://#{hostname}/#{path}#{q}".sub(%r{(/)+$}, "")
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
      env_var = app_name.to_s.upcase + "_URL"
      ENV[env_var]
    end
  end

  class InvalidPCOURLString < StandardError; end
end
