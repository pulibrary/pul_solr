source 'https://rubygems.org'

gem 'stringex', :git => 'https://github.com/pulibrary/stringex.git', :tag => 'vpton.2.5.2.2'

gem 'capistrano-bundler'
gem 'faraday'
gem 'rake'
gem 'rsolr'
gem 'whenever'

group :development do
  gem 'bcrypt_pbkdf'
  gem 'capistrano', '~> 3.9'
  gem 'ed25519'
  gem 'rbnacl', '< 5.0'
  gem 'rbnacl-libsodium'
end

group :test do
  gem 'rspec', '~> 3.8'
  gem 'rspec-solr', '~> 3.0'
  gem 'webmock'
end

group :development, :test do
  gem 'pry-byebug'
end
