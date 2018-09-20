require "spec_helper"

describe PCO::URL::Encryption do
  # rubocop:disable Metrics/LineLength
  TEST_DEFAULT_KEY = "\xE3\x9B\"f\x13\xAD\xDE\xC0(t\x03\x16c\xE2\xE4\x9B\xC7Cj k\xDA\xDB\xA9\xE3\xAB\x96\xE4\xA7`\v\x87".freeze
  TEST_SPECIFIC_KEY = "A\xA0\xBA\x9FX\xD1\x82\xED\xDB\xD5cx|[\xB3\xE6i\xE7\xA3R\xAF(\xFC\xA4?\xC6\xC3\x7F\xEAu\x90u".freeze
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
        encrypted = "t08dkbvdv0zs27n38AykgbsxlyZpw73jh6vyjrwxy3Akvdqh4xwzm"

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
      encrypted = "3pyb298n27c1k2bcx4r8mAb751Zm12wmAytksfjnq1f4wjdd23dh991k1flr6xqvhtbjlchrnwA4znq"

      expect(described_class.decrypt(encrypted, key: TEST_SPECIFIC_KEY)).to eq("Do the funky Spiderman")
    end
  end
end
