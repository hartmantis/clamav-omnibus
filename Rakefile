# -*- encoding: utf-8 -*-

require 'rubygems'
require 'bundler/setup'
require 'rubocop/rake_task'
require 'kitchen/rake_tasks'

Rubocop::RakeTask.new do |task|
  task.patterns = %w{**/*.rb}
end

Kitchen::RakeTasks.new

task default: %w{rubocop kitchen:all}

# vim: ai et ts=2 sts=2 sw=2 ft=ruby
