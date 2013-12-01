source 'http://ruby.taobao.org'

gem 'rake'

# A database backend that translates database interactions into no-ops. Using
# NullDB enables you to test your model business logic - including after_save
# hooks - without ever touching a real database.
gem "activerecord-nulldb-adapter", github: "nulldb/nulldb"

gemspec

group :test do
  gem 'paperclip'
  gem 'rest-client'
  gem 'rspec'
  gem 'pry'
  gem 'pry-nav'
end
