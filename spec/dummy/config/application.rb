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
      config.hosts << "accounts-staging.planningcenteronline.com"
      config.hosts << "accounts-staging.planningcenter.com"

      # We would obviously never have this in a real Rails app, but we need it here
      # to test that PCO::URL cannot get tricked by a bad host, should an attacker
      # somehow sneak one through by some other means.
      config.hosts << "accounts.evilplanningcenter.com"
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
