module PCO
  class URL
    class Engine < Rails::Engine
      class DomainMiddleware
        def initialize(app)
          @app = app
        end

        def call(env)
          PCO::URL::Engine.domain = env["SERVER_NAME"].downcase.match(/[a-z0-9-]+\.[a-z]+$/).to_s
          @app.call(env)
        end
      end
    end
  end
end
