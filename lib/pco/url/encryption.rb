# Sourced from https://github.com/cheerful/URLcrypt/blob/v0.1.1/lib/URLcrypt.rb
#
# Copyright (c) 2013-2015 Thomas Fuchs
# Copyright (c) 2007-2011 Samuel Tesla
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require "openssl"

module PCO
  class URL
    module Encryption
      class DecryptError < ::ArgumentError; end
      class MissingKeyError < ::ArgumentError; end

      # avoid vowels to not generate four-letter words, etc.
      # this is important because those words can trigger spam
      # filters when URLs are used in emails
      TABLE = "1bcd2fgh3jklmn4pqrstAvwxyz567890".freeze

      class Chunk
        def initialize(bytes)
          @bytes = bytes
        end

        def decode # rubocop:disable Metrics/AbcSize
          bytes = @bytes.take_while { |c| c != 61 } # strip padding
          bytes = bytes.find_all { |b| !TABLE.index(b.chr).nil? } # remove invalid characters
          n = (bytes.length * 5.0 / 8.0).floor
          p = bytes.length < 8 ? 5 - (n * 8) % 5 : 0
          c = bytes.inject(0) { |m, o| (m << 5) + TABLE.index(o.chr) } >> p
          (0..(n - 1)).to_a.reverse.collect { |i| ((c >> i * 8) & 0xff).chr }
        end

        def encode # rubocop:disable Metrics/AbcSize
          n = (@bytes.length * 8.0 / 5.0).ceil
          p = n < 8 ? 5 - (@bytes.length * 8) % 5 : 0
          c = @bytes.inject(0) { |m, o| (m << 8) + o } << p
          [
            (0..(n - 1)).to_a.reverse.collect { |i| TABLE[(c >> i * 5) & 0x1f].chr },
            ("=" * (8 - n))
          ]
        end
      end

      class << self
        def default_key=(key)
          raise(<<~ERR) if defined?(@default_key) && @default_key != key
            Don't change the default_key during the life of a process.
            This configuration variable is meant to be set once on boot and not
            touched again.

            If your app needs to use multiple keys, pass them in explicitly to `encrypt`
            and `decrypt`
          ERR

          @default_key = key
        end

        def decrypt(data, key: @default_key)
          raise MissingKeyError, "default key or key: argument must be set" if key.nil?
          iv, encrypted = case_corrected(data).split("Z").map { |part| decode(part) }
          raise DecryptError, "not a valid string to decrypt" unless iv && encrypted
          decrypter = cipher(:decrypt, key: key)
          decrypter.iv = iv
          decrypter.update(encrypted) + decrypter.final
        end

        def encrypt(data, key: @default_key)
          raise MissingKeyError, "default key or key: argument must be set" if key.nil?
          crypter = cipher(:encrypt, key: key)
          crypter.iv = iv = crypter.random_iv
          "#{encode(iv)}Z#{encode(crypter.update(data) + crypter.final)}"
        end

        private

        def case_corrected(data)
          return data unless data[26] == "z"
          data.tr("a", "A").gsub(/([#{TABLE}]{26})z/, '\1Z')
        end

        def chunks(str, size)
          result = []
          bytes = str.bytes
          while bytes.any?
            result << Chunk.new(bytes.take(size))
            bytes = bytes.drop(size)
          end
          result
        end

        # strip "=" padding, because we don"t need it
        def encode(data)
          chunks(data, 5).collect(&:encode).flatten.join.tr("=", "")
        end

        def decode(data)
          chunks(data, 8).collect(&:decode).flatten.join
        end

        def cipher(mode, key:)
          cipher = OpenSSL::Cipher.new("aes-256-cbc")
          cipher.public_send(mode)
          cipher.key = key
          cipher
        end
      end
    end
  end
end
