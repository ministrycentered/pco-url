gemfile = File.expand_path('../../../../Gemfile', __FILE__)
ENV['BUNDLE_GEMFILE'] = gemfile
require 'bundler'
Bundler.setup
$LOAD_PATH.unshift(File.expand_path('../../../../lib', __FILE__))
