# Encoding: UTF-8

require 'rubygems'
require 'bundler/setup'
require 'rubocop/rake_task'
require 'fog'
require 'kitchen'
require 'kitchen/rake_tasks'

module ClamAVOmnibus
  # Helper methods for uploading and deleting DigitalOcean build keys
  #
  # @author Jonathan Hartman <j@p4nt5.com>
  class Helpers
    def self.instances
      Kitchen::Config.new(
        loader: Kitchen::Loader::YAML.new(
          project_config: ENV['KITCHEN_YAML'],
          local_config: ENV['KITCHEN_LOCAL_YAML'],
          global_config: ENV['KITCHEN_GLOBAL_YAML']
        )
      ).instances
    end

    def self.compute
      Fog::Compute.new(provider: 'DigitalOcean',
                       digitalocean_client_id: ENV['DIGITALOCEAN_CLIENT_ID'],
                       digitalocean_api_key: ENV['DIGITALOCEAN_API_KEY'])
    end

    def self.key_name
      "clamav-omnibus-deploy-#{ENV['TRAVIS_BUILD_NUMBER']}"
    end

    def self.private_key_file
      File.expand_path('~/.ssh/id_rsa')
    end

    def self.public_key_file
      "#{private_key_file}.pub"
    end

    def self.ssh_key
      private_key_file
    end

    def self.ssh_key_ids
      compute.ssh_keys.map do |k|
        k.id if k.name == key_name
      end.compact.join(', ')
    end

    def self.upload_key_to_digitalocean!
      unless compute.ssh_keys.index { |k| k.name == key_name }
        compute.ssh_keys.create(name: key_name,
                                ssh_pub_key: File.open(public_key_file).read)
      end
      ssh_key_ids
    end

    def self.delete_key_from_digitalocean!
      compute.ssh_keys.each { |k| k.destroy if k.name == key_name }
    end
  end
end

RuboCop::RakeTask.new

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

  task :clean_up_keys do
    delete_key_from_digitalocean!
  end

  ClamAVOmnibus::Helpers.instances.each do |i|
    desc "Build and deploy for #{i.name}"
    task i.name do
      i.converge
      i.verify
      deploy(i) if ENV['TRAVIS_BRANCH'] == 'master'
      i.destroy
    end
  end

  desc 'Destroy all build instances'
  task :destroy do
    ClamAVOmnibus::Helpers.instances.each { |i| i.destroy }
  end

  desc 'Destroy all build instances and clean up temp keys'
  task clean_up: %w(destroy clean_up_keys)

  desc 'Build and deploy for all instances'
  task all: ClamAVOmnibus::Helpers.instances.map { |i| i.name }

  task default: %w(all clean_up)
end

task build_and_deploy: %w(build_and_deploy:default)

task default: %w(rubocop build_and_deploy)
