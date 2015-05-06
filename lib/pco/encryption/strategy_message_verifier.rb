require 'rack'
require 'active_support/all'

class StrategyMessageVerifier
  def initialize
    @verifier = ActiveSupport::MessageVerifier.new('sekrit')
  end

  def encrypt(message)
    Rack::Utils.escape_path(@verifier.generate(message))
  end

  def decrypt(signed_token)
    @verifier.verify(Rack::Utils.unescape(signed_token).gsub(/ /, ''))
  end
end
