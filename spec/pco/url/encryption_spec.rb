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

  context "the original URLcrypt tests" do
    def private_encode(plain)
      described_class.send(:encode, plain)
    end

    def private_decode(encded)
      described_class.send(:decode, encded)
    end

    def expect_bytes_equal(string1, string2)
      bytes1 = string1.bytes.to_a.join(":")
      bytes2 = string2.bytes.to_a.join(":")
      expect(bytes1).to eq(bytes2)
    end

    def expect_decoding(encoded, plain)
      expect_bytes_equal(plain, private_decode(encoded))
    end

    def expect_encoding(encoded, plain)
      expect_bytes_equal(encoded, private_encode(plain))
    end

    it "test empty string" do
      expect_encoding("", "")
      expect_decoding("", "")
    end

    it "encodes and decodes properly" do
      encoded = "111gc86f4nxw5zj1b3qmhpb14n5h25l4m7111"
      plain = "\0\0awesome \n ü string\0\0"

      expect_encoding(encoded, plain)
      expect_decoding(encoded, plain)
    end

    it "test invalid decoding" do
      expect_decoding("ZZZZZ", "")
    end

    it "test arbitrary byte strings" do
      0.step(1500, 17) do |n|
        original = (0..n).map { rand(256).chr }.join
        encoded = private_encode(original)
        expect_decoding(encoded, original)
      end
    end

    it "test encryption" do
      described_class.default_key =
        "I\x12 \xC8=\xC5\xE6\xB8fJq\xAF\x15\xF37\b\x7F\"\xDB\xCFMzf\xD5\xA3\xD3)\xBA2\xF9F\x03"

      original  = "hello world!"
      encrypted = described_class.encrypt(original)
      expect(described_class.decrypt(encrypted)).to eq(original)
    end

    it "test decrypt error" do
      described_class.default_key = "some key"
      expect { described_class.decrypt("just some plaintext") }
        .to raise_error(described_class::DecryptError)
        .with_message("not a valid string to decrypt")
    end
  end
end
