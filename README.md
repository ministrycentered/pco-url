# PCO::URL

[![CircleCI](https://circleci.com/gh/ministrycentered/pco-url.svg?style=svg)](https://circleci.com/gh/ministrycentered/pco-url)

Fetch the base URL for the current and other applications based on the current application environment.

## Usage

Uses `Rails.env` by default to determine the environment name.

Set `ENV["DEPLOY_ENV"]` to override this default.

```ruby
ENV["DEPLOY_ENV"] = "staging"

Rails.env
# => "production"

PCO::URL.accounts
# => "https://accounts-staging.planningcenteronline.com"
```

For individual apps, change an environment variable to specify the URL for a given app:

```ruby
ENV["ACCOUNTS_URL"] = "https://accounts-test1.planningcenteronline.com"

Rails.env
# => "staging"

PCO::URL.accounts
# => "https://accounts-test1.planningcenteronline.com"

PCO::URL.services
# => "https://services-staging.planningcenteronline.com"
```


You can also specify the path:


```ruby
PCO::URL.accounts("/test")
# => "https://accounts-test1.planningcenteronline.com/test"

PCO::URL.accounts("test")
# => "https://accounts-test1.planningcenteronline.com/test"

PCO::URL.accounts("test", "working")
# => "https://accounts-test1.planningcenteronline.com/test/working"
```

### Encryption

`pco-url` includes URL-safe encryption utilites in the `PCO::URL::Encryption` module.

It uses `aes-256-cbc` for encryption, and the code is ported from [URLcrypt](https://github.com/cheerful/URLcrypt).

The encryption/decryption key **should** be 32 bytes. In Ruby <= 2.3, a longer key will be automatically truncated by the `OpenSSL` library, but starting with Ruby >= 2.4, the encryption will fail if the key is not exactly 32 bytes. If you currently are using a key that isn't 32 bytes, you will have to change the key to upgrade to Ruby 2.4.

#### Setup

`PCO::URL::Encryption` can be used with a global default encryption key, or a specific key for each encrypt/decrypt step.

To set a default key:

```ruby
# for example, in an initializer

PCO::URL::Encryption.default_key = "32 bytes of randomness"
```

**note:** if you set a default key, `pco-url` will raise an error on any attempt to modify the default key. If you need to use multiple keys in your app, use the keyword argument syntax to set it for each encryption/decryption.

#### Usage

To encrypt with the global default key

```ruby
# encrypt with the global default key
PCO::URL::Encryption.encrypt("sekret") # => qmj1w631bs6hd3cyf8h5kv37n3Zxxvgyr4j5jvsll0x65f7vcm9sm

# decrypt with the global default key
PCO::URL::Encryption.decrypt("qmj1w631bs6hd3cyf8h5kv37n3Zxxvgyr4j5jvsll0x65f7vcm9sm") # => sekret

# encrypt with a specific key
thirty_two_byte_string = "192c0ba7369e27f4b04fa304030712c8"

PCO::URL::Encryption.encrypt("sekret", key: thirty_two_byte_string) # => rxnfnstyt6fvs618A8Abwtg1c1Zyqhgf0lhtqtmypc4t0zlhxyr02

PCO::URL::Encryption.decrypt("rxnfnstyt6fvs618A8Abwtg1c1Zyqhgf0lhtqtmypc4t0zlhxyr02", key: thirty_two_byte_string) # => sekret
```
