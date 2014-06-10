# Encoding: UTF-8

require 'rubygems'
require 'bundler/setup'
require 'rubocop/rake_task'
require 'kitchen'
require 'kitchen/rake_tasks'

RuboCop::RakeTask.new do |task|
  task.patterns = %w(**/*.rb)
end

Kitchen::RakeTasks.new

namespace :build_and_deploy do
  # Hack up the run_list to make an already-converged-and-verified instance
  # do a deploy.
  #
  # TODO: What if Test Kitchen itself had a `deploy` action? Or should that
  # stay the realm of the CI server running Kitchen? The only reason we need
  # this hackery here is for lack of a folder syncing in the DigitalOcean
  # driver to pull the artifact back down.
  def deploy(instance)
    config = instance.provisioner.instance_variable_get(:@config)
    config[:run_list] = %w(recipe[clamav-omnibus::deploy])
    instance.converge
  end

  instances = Kitchen::Config.new.instances

  instances.each do |i|
    desc "Build and deploy for #{i.name}"
    task i.name do
      i.converge && i.verify && deploy(i) && i.destroy
    end
  end

  desc 'Build and deploy for all instances'
  task all: instances.map { |i| i.name }

  task default: %w(rubocop all)
end

task default: %w(rubocop kitchen:all)
