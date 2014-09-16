require "pco/url/version"

module PCO
  class URL
    class << self
      def accounts
        ENV["ACCOUNTS_URL"] || url_for_app("accounts")
      end

      def services
        ENV["SERVICES_URL"] || url_for_app("services")
      end

      def people
        ENV["PEOPLE_URL"] || url_for_app("people")
      end

      def check_ins
        ENV["CHECK_INS_URL"] || url_for_app("check-ins")
      end

      def resources
        ENV["RESOURCES_URL"] || url_for_app("resources")
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
