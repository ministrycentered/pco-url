require "rspec"
require "pco/url"

RSpec.configure do |config|
  config.color = true
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end

class Rails
  class << self
    attr_accessor :env
  end
end
