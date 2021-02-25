# frozen_string_literal: true

require "rails/engine"

module PCO
  class URL
    class Engine < Rails::Engine
      class DomainMiddleware
        def initialize(app)
          @app = app
        end

        def call(env)
          domain = env["SERVER_NAME"].downcase.match(/[a-z0-9-]+\.[a-z]+$/).to_s
          PCO::URL::Engine.domain = PCO::URL::DOMAINS[Rails.env].include?(domain) ? domain : nil
          @app.call(env)
        end
      end
    end
  end
end
