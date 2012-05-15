# Provide a simple gemspec so you can easily use your enginex
# project in your rails apps through git.
require File.expand_path('../lib/oauth_provider_engine/version', __FILE__)
Gem::Specification.new do |s|
  s.name = "oauth_provider_engine"
  s.version = OauthProviderEngine::VERSION
  s.summary = 'A Rails Engine that allow the site to act as an OAuth provider'
  s.add_dependency "rails", ">= 3.0.0"
  s.add_dependency "oauth", "~> 0.4.0"

  s.author = "Jeff Ching"
  s.email = "jeff@chingr.com"
  s.homepage = "http://github.com/chingor13/oauth_provider_engine"
  s.extra_rdoc_files = ['README.rdoc']
  s.has_rdoc = true

  s.files = Dir['lib/**/*.rb'] + Dir['test/**/*.rb']
  s.test_files = Dir.glob('test/*_test.rb')
end
