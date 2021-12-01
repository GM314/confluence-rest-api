Gem::Specification.new do |s|
  s.name    = %q{confluence-rest-api}
  s.version = "1.2.0"
  s.date    = %q{2021-12-01}
  s.summary = %q{Ruby REST API Client to create, update, and view pages}
  s.authors = "Gregory J. Miller, Rolf Offermanns"
  s.files   = [
      "lib/confluence-rest-api.rb", "lib/confluence.rb", "lib/page.rb", "lib/storage_format.rb", "README.md", "confluence-rest-api.gemspec"
  ]
  s.license       = "MIT"
  s.homepage      = "https://github.com/GM314/confluence-rest-api"
  s.add_runtime_dependency 'rest-client', '~> 2.0', '>= 2.0.0'
  s.add_runtime_dependency 'json', '~> 2.3', '>= 2.3.1'
  s.add_runtime_dependency 'addressable', '~> 2.3', '>= 2.3.7'
  s.add_runtime_dependency 'nokogiri', '~> 1.6', '>= 1.6.8'
end
