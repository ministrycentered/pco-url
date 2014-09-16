require "rspec"
require "pco/url"

RSpec.configure do |config|
  config.color = true
end

class Rails
  class << self
    attr_accessor :env
  end
end
