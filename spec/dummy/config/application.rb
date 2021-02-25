# frozen_string_literal: true

require_relative "./boot"
require "action_controller/railtie"

require "pco/url"

module Dummy
  class Application < Rails::Application
    config.eager_load = false
    if Rails::VERSION::MAJOR >= 6
      config.hosts << "accounts.pco.test"
      config.hosts << "accounts.pco.codes"
      config.hosts << "accounts.planningcenteronline.com"
      config.hosts << "accounts.planningcenter.com"
    end
    config.secret_key_base = "123abc"
  end
end

Dummy::Application.initialize!

class TestsController < ActionController::Base
  def show
    render plain: PCO::URL.people
  end
end

Rails.application.routes.draw do
  resource :test
end
