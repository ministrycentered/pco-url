require "spec_helper"

describe PCO::Encryption do
  let(:message) { 'hello world' }
  describe 'encrypt' do
    context 'of a urlcrypt message' do
      let(:encrypted_message) { PCO::Encryption.encrypt(message, strategy: StrategyUrlCrypt.new) }
      it 'should be different than plaintext' do
        expect(encrypted_message).not_to eq(message)
      end
      it 'should be reversible via fallthrough strategy' do
        expect(PCO::Encryption.decrypt(encrypted_message)).to eq(message)
      end
    end
    context 'of a verified message' do
      let(:encrypted_message) { PCO::Encryption.encrypt(message, strategy: StrategyMessageVerifier.new) }
      it 'should be different than plaintext' do
        expect(encrypted_message).not_to eq(message)
      end
      it 'should be reversible via fallthrough strategy' do
        expect(PCO::Encryption.decrypt(encrypted_message)).to eq(message)
      end
    end
  end
end
