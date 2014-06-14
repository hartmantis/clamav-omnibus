# Encoding: UTF-8

require 'rubygems'
require 'bundler/setup'
require 'rubocop/rake_task'
require 'fog'
require 'kitchen'
require 'kitchen/rake_tasks'

def instances
  Kitchen::Config.new.instances
end

def compute
  Fog::Compute.new(provider: 'DigitalOcean',
                   digitalocean_client_id: ENV['DIGITALOCEAN_CLIENT_ID'],
                   digitalocean_api_key: ENV['DIGITALOCEAN_API_KEY'])
end

def kitchen_keys
  instances.map { |i| i.driver[:ssh_key] }.uniq
end

def key_name(index)
  "clamav-omnibus-deploy-#{ENV['TRAVIS_BUILD_NUMBER']}-#{index}"
end

def ssh_key_ids
  kitchen_keys.map.with_index do |_, i|
    key_name(i)
  end.join(', ')
end

def upload_keys_to_digitalocean!
  kitchen_keys.each_with_index do |k, i|
    compute.ssh_keys.create(name: key_name(i),
                            ssh_pub_key: File.open("#{k}.pub").read)
  end
end

def delete_keys_from_digitalocean!
  kitchen_keys.each_with_index do |_, i|
    compute.ssh_keys.each { |kobj| kobj.destroy if kobj.name == key_name(i) }
  end
end

ENV['DIGITALOCEAN_SSH_KEY_IDS'] = ssh_key_ids

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

  # TODO: Move these key management pieces out to their own library somewhere
  task :deploy_keys do
    upload_keys_to_digitalocean!
  end

  task :clean_up_keys do
    delete_keys_from_digitalocean!
  end

  instances.each do |i|
    desc "Build and deploy for #{i.name}"
    task i.name do
      i.converge && i.verify && deploy(i) && i.destroy
    end
  end

  desc 'Build and deploy for all instances'
  task all: instances.map { |i| i.name }

  task default: %w(deploy_keys all clean_up_keys)
end

task build_and_deploy: %w(build_and_deploy:default)

task default: %w(rubocop build_and_deploy)
