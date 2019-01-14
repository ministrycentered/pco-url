module PCO
  class URL
    class Avatars < URL
      def initialize(app_name: "avatars", path: nil, query: nil, encrypt_query_params: false, domain: nil)
        super
      end

      def hostname
        "#{app_name}.#{domain}"
      end
    end
  end
end
