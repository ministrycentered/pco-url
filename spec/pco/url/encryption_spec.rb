require "spec_helper"

describe PCO::URL::Encryption do
  # rubocop:disable Metrics/LineLength
  TEST_DEFAULT_KEY = "b01b94f55e543afee167392ea43f8245".freeze
  TEST_SPECIFIC_KEY = "97f44346e1cfa9f5fc19463fd182c495".freeze
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
        encrypted = "gktp1A49k6kmbz7ktfwrzwlmc2Zn8t95d4lq9bc62mr252d0542k1"

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
      encrypted = "lbklbyhw9pkgs3mqtc5p000xz1Zqrdrkf1f3phmhvzfksgg2Aqdg78kngpv3r5zz1fll6z5cvn96j11"

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
      described_class.default_key = "3c3ff314c12b786da43a50b571c0aedc"

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
