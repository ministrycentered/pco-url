module PCO
  class URL
    class ChurchCenter < URL
      def initialize(app_name: "church-center", path: nil, query: nil, encrypt_query_params: false, domain: nil)
        super
      end

      def domain
        return @domain if @domain
        case env
        when "production", "staging"
          "churchcenteronline.com"
        when "development"
          "churchcenter.dev"
        when "test"
          "churchcenter.test"
        end
      end

      def hostname
        super if env_overridden_hostname
        if env == "staging"
          "staging.#{domain}"
        else
          domain
        end
      end
    end
  end
end
