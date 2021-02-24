require_relative "./engine/domain_middleware"

module PCO
  class URL
    class Engine < Rails::Engine
      def self.domain
        Thread.current[:pco_url_domain]
      end

      def self.domain=(d)
        Thread.current[:pco_url_domain] = d
      end

      initializer "pco_url.add_middleware" do |app|
        app.middleware.use PCO::URL::Engine::DomainMiddleware
      end
    end
  end
end
