source 'https://rubygems.org'

gem 'stringex', :git => 'https://github.com/pulibrary/stringex.git', :tag => 'vpton.2.5.2.2'

gem 'base64'
gem 'bigdecimal'
gem 'capistrano-bundler'
gem 'faraday'
gem 'logger'
gem 'ostruct'
gem 'rake'
gem 'rsolr'

# RSpec should be in the test group, however rake tasks
# try to load tasks from Rspec, and this causes backups
# to fail.  Make sure backups work before moving it to
# the test group.
gem 'rspec', '~> 3.8'
gem 'whenever'

group :development do
  gem 'bcrypt_pbkdf'
  gem 'capistrano', '~> 3.9'
  gem 'ed25519'
  gem 'rbnacl', '< 5.0'
  gem 'rbnacl-libsodium'
end

group :test do
  gem 'rspec-solr', '~> 3.0'
  gem 'webmock'
end

group :development, :test do
  gem 'pry-byebug'
end
