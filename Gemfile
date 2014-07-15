# Encoding: UTF-8

source 'https://rubygems.org'

group :build_node do
  gem 'omnibus', '~> 3.2.0.rc'
  gem 'omnibus-software', github: 'opscode/omnibus-software'
end

group :control_node do
  gem 'rake'
  gem 'berkshelf'
  gem 'rubocop'
  gem 'test-kitchen'
  gem 'kitchen-digitalocean'
  gem 'kitchen-vagrant'
  gem 'vagrant-wrapper'
end
