require "spec_helper"

describe PCO::URL::Encryption do
  # rubocop:disable Metrics/LineLength
  TEST_DEFAULT_KEY = "\x8Bh\xFAsQ\xF9\xE0u]W#Al8\xC5\xF7\x19\x006+\xF8\xD08i\x12,\xE6X4pna".freeze
  TEST_SPECIFIC_KEY = "-u\x9F\x15g\xA8j`C\x0F\x1D\xE2\xC5\xEF\x90\xA2\x14\xBF\xFE\xF8\x83T\x13\xE1\xC7\xE3N\x8F1v\x8C\xEC".freeze
  # rubocop:enable Metrics/LineLength

  after { reset_encryption_default_key }

  it "gets mad if you try to change the default key" do
    described_class.default_key = "key!"

    expect { described_class.default_key = "new key!" }.to raise_error(/change the default_key/i)
  end

  context "without a specific key" do
    context "when a default key is set" do
      it "encrypts and decrypts correctly" do
        described_class.default_key = TEST_DEFAULT_KEY
        encrypted = described_class.encrypt("BoJack")
        decrypted = described_class.decrypt(encrypted)

        expect(decrypted).to eq("BoJack")
      end

      it "decrypts correctly" do
        described_class.default_key = TEST_DEFAULT_KEY
        encrypted = "8zptAtk2wfnsvbsA6k985s82h3Z882hrk2Aw7l5lmtpdryk80rgdm"

        expect(described_class.decrypt(encrypted)).to eq("Horseman")
      end
    end

    context "when no default key is set" do
      it "fails loudly because no key is set" do
        expect { described_class.encrypt("value") }.to raise_error(described_class::MissingKeyError)
        expect { described_class.decrypt("value") }.to raise_error(described_class::MissingKeyError)
      end
    end
  end

  context "using a specified key" do
    it "encrypts and decrypts correctly" do
      encrypted = described_class.encrypt("You are Secretariat", key: TEST_SPECIFIC_KEY)
      decrypted = described_class.decrypt(encrypted, key: TEST_SPECIFIC_KEY)

      expect(decrypted).to eq("You are Secretariat")
    end

    it "decrypts correctly" do
      encrypted = "xps9AA7wdqdz50Axh79rb5rmzyZy48qy32v9jds0tkA6mhtn0wxs4sbg3y03l4wwnq6gf79tsk530pq"

      expect(described_class.decrypt(encrypted, key: TEST_SPECIFIC_KEY)).to eq("Do the funky Spiderman")
    end
  end
end
