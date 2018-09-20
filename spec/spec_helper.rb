require "rspec"
require "pco/url"

RSpec.configure do |config|
  config.color = true
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  def reset_encryption_default_key
    return unless PCO::URL::Encryption.instance_variable_defined?(:@default_key)
    PCO::URL::Encryption.remove_instance_variable(:@default_key)
  end
end

class Rails
  class << self
    attr_accessor :env
  end
end
