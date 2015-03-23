require "pco/url/version"
require 'uri'
require 'base64'

module PCO
  class URL

    SALT = 'These_pretzels_are_making_me_thirsty'

    class << self
      def method_missing(method_name, *args)
        url_for_app_with_path(method_name, args)
      end

      def encrypt_params(params)
        Rack::Utils.escape_path(Base64.encode64(params + "&salt=#{SALT}"))
      end

      def decrypt_params(encrypted_params)
        query = Base64.decode64(Rack::Utils.unescape(encrypted_params))
        parsed = Rack::Utils.parse_query(query)
        parsed.delete "salt"
        parsed
      end

      private

      def env
        ENV["DEPLOY_ENV"] || Rails.env
      end

      def env_url(app_name)
        env_var  = app_name.to_s.upcase + "_URL"
        ENV[env_var]
      end

      def url_for_app_with_path(app_name, paths)
        path = paths.map { |p| p.sub(/\A\/+/, "").sub(/\/+\Z/, "") }.join("/")

        URI::join(url_for_app(app_name), path).to_s
      end

      def url_for_app(app_name)
        # Try "CHECK_INS_URL" then url_for_app("check-ins")
        return env_url(app_name) if env_url(app_name)

        app_name = app_name.to_s.gsub("_", "-")
        case env
        when "production"
          "https://#{app_name}.planningcenteronline.com"
        when "staging"
          "https://#{app_name}-staging.planningcenteronline.com"
        when "development"
          "http://#{app_name}.pco.dev"
        when "test"
          "http://#{app_name}.pco.test"
        end
      end
    end

  end
end
