require_relative "./boot"
require "action_controller/railtie"

require 'pco/url'

module Dummy
  class Application < Rails::Application
    config.eager_load = false
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
