Gem::Specification.new do |s|
  s.name    = %q{confluence-rest-api}
  s.version = "1.0.9"
  s.date    = %q{2020-08-25}
  s.summary = %q{Ruby REST API Client to create, update, and view pages}
  s.authors = "Gregory J. Miller"
  s.files   = [
      "lib/confluence-rest-api.rb", "lib/confluence.rb", "lib/page.rb", "lib/storage_format.rb", "README.md", "confluence-rest-api.gemspec"
  ]
  s.license       = "MIT"
  s.homepage      = "https://github.com/grmi64/confluence-rest-api"
  s.add_runtime_dependency 'rest-client', '~> 2.0', '>= 2.0.0'

end
