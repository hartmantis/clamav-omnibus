# Encoding: UTF-8

source 'https://rubygems.org'

group :build_node do
  gem 'omnibus', '~> 4.0.0.beta'
  gem 'omnibus-software', github: 'opscode/omnibus-software'
end

group :control_node do
  gem 'rake'
  gem 'berkshelf'
  gem 'rubocop'
  gem 'test-kitchen'
  gem 'kitchen-digitalocean'
  gem 'kitchen-vagrant'
end
