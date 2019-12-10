# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pco/url/version'

Gem::Specification.new do |spec|
  spec.name          = "pco-url"
  spec.version       = PCO::URL::VERSION
  spec.authors       = ["James Miller"]
  spec.email         = ["bensie@gmail.com"]
  spec.summary       = %q{Generate URLs for PCO apps in all environments}
  spec.homepage      = "https://github.com/ministrycentered/pco-url"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rails"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "rubocop"
end
