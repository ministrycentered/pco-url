require 'active_support/all'
require 'pco/encryption/strategy_url_crypt'
require 'pco/encryption/strategy_message_verifier'

module PCO
  class Encryption
    class << self
      def encrypt(message, strategy: StrategyUrlCrypt.new)
        strategy.encrypt(message)
      end

      def decrypt(message)
        decrypt_via_url_crypt(message) || decrypt_via_message_verifier(message)
      end

      def decrypt_via_url_crypt(message, strategy: StrategyUrlCrypt.new)
        strategy.decrypt(message)
      rescue URLcrypt::DecryptError, OpenSSL::Cipher::CipherError
        nil
      end

      def decrypt_via_message_verifier(message, strategy: StrategyMessageVerifier.new)
        strategy.decrypt(message)
      rescue ActiveSupport::MessageVerifier::InvalidSignature
        nil
      end
    end
  end
end
