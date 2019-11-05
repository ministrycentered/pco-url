require_relative "./engine/domain_middleware"

module PCO
  class URL
    class Engine < Rails::Engine
      thread_cattr_accessor :domain

      initializer "pco_url.add_middleware" do |app|
        app.middleware.use PCO::URL::Engine::DomainMiddleware if Rails.env.development? || Rails.env.test?
      end
    end
  end
end
