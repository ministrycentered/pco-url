require "pco/url/version"

module PCO
  class URL
    class << self
      REAL_APPS = [:accounts, :people, :services, :resources, :check_ins]
      def method_missing(method_name)
        if !REAL_APPS.include?(method_name)
          raise ArgumentError, "#{method_name} isn't a real app! (Must be in #{REAL_APPS.join(", ")})"
        end
        app_name = method_name.to_s.gsub("_", "-")
        env_var  = method_name.to_s.upcase + "_URL"
        # try "CHECK_INS_URL" then url_for_app("check-ins")
        ENV[env_var] || url_for_app(app_name)
      end

      private

      def env
        ENV["DEPLOY_ENV"] || Rails.env
      end

      def url_for_app(app_name)
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
