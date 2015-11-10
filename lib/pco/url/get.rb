module PCO
  class URL
    class Get < URL
      def initialize(app_name: "get", path: nil, query: nil, encrypt_query_params: false, domain: nil)
        super
      end

      def scheme
        "http"
      end
    end
  end
end
