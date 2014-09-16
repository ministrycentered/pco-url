require "pco/url/version"

module PCO
  class URL
    Applications = [
      :accounts,
      :services,
      :check_ins,
      :people,
      :registrations,
      :resources
    ]

    class << self
      def method_missing(method_name)
        if Applications.include? method_name
          app_name = method_name.to_s.gsub("_", "-")
          env_var  = method_name.to_s.upcase + "_URL"

          # Try "CHECK_INS_URL" then url_for_app("check-ins")
          ENV[env_var] || url_for_app(app_name)
        else
          super
        end
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
