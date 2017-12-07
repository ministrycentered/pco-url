module PCO
  class URL
    class ChurchCenter < URL
      def initialize(app_name: "church-center", path: nil, query: nil, encrypt_query_params: false, domain: nil, subdomain: nil)
        super(
          app_name: app_name,
          path: path,
          query: query,
          encrypt_query_params: encrypt_query_params,
          domain: domain
        )
        @subdomain = subdomain
      end

      def domain
        return @domain if @domain
        case env
        when "production", "staging"
          "churchcenter.com"
        when "development", "test"
          "churchcenter.test"
        end
      end

      def hostname
        super if env_overridden_hostname
        sub = "#{@subdomain}." if @subdomain
        if env == "staging"
          "#{sub}staging.#{domain}"
        else
          "#{sub}#{domain}"
        end
      end
    end
  end
end
