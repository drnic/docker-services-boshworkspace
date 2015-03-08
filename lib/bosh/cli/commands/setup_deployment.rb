$:.unshift(File.expand_path("../../../..", __FILE__))
require "bosh/cloud_deployment"

# for the #sh helper
require "rake"
require "rake/file_utils"

module Bosh::Cli::Command
  class SetupDeployment < Base
    include FileUtils

    attr_reader :cf

    usage "setup deployment"
    desc "Prompt user to setup Docker services prior to deployment"
    option '--deployment-name NAME', 'Name this deployment. Default: my-docker-services-<CPI>'
    option '--cf-deployment-name NAME', 'Select Cloud Foundry deployment name, instead of menu'
    def setup_deployment
      cf_deployment_name = options[:cf_deployment_name]
      cf_deployment_name ||= prompt_for_deployment("cf")

      say "Looking up '#{cf_deployment_name}'..."
      unless cf_manifest = director.get_deployment(cf_deployment_name)["manifest"]
        err "Deployment '#{cf_deployment_name}' has not completed successfully yet."
      end
      @cf = YAML.load(cf_manifest)

      deployment_name = options[:deployment_name]
      deployment_name ||= "my-docker-services-#{cpi}"

      cloud_deployment = Bosh::CloudDeployment.cloud(cpi)
      cloud_deployment.director_uuid = director.uuid
      cloud_deployment.cf = @cf
      cloud_deployment.deployment_name = deployment_name
      cloud_deployment.setup

      if cf_services = choose_one_or_all_cf_services
        cloud_deployment.cf_services = cf_services
      end

      deployment_stub_file = "deployments/#{cloud_deployment.deployment_name}.yml"
      File.open(deployment_stub_file, "w") do |f|
        f << cloud_deployment.manifest_stub.to_yaml
      end
      sh "bosh deployment #{deployment_stub_file}"

    end


    private
      # return which CPI is being used
      # determined based on name of stemcell used in 'cf' deployment
      def cpi
        @cpi ||= begin
          if cf_stemcell_name =~ /warden/
            "warden"
          elsif cf_stemcell_name =~ /aws/
            "aws"
          elsif cf_stemcell_name =~ /openstack/
            "openstack"
          elsif cf_stemcell_name =~ /vsphere/
            "vsphere"
          else
            err "Unable to determine CPI from Cloud Foundry stemcell '#{cf_stemcell_name}'"
          end
        end
      end

      # return name of stemcell used within Cloud Foundry deployment
      def cf_stemcell_name
        cf["resource_pools"].first["stemcell"]["name"]
      end

      def prompt_for_deployment(includes_release)
        names = director.list_deployments.map { |deployment| deployment["name"] }
        # filter by includes_release
        names = names.inject([]) do |list, deployment_name|
          if manifest_yaml = director.get_deployment(deployment_name)["manifest"]
            manifest = YAML.load(manifest_yaml)
            releases = manifest["releases"].map {|rel| rel["name"]}
            if releases.include?(includes_release)
              list << deployment_name
            end
          end
          list
        end
        if names.size == 0
          err "No Cloud Foundry deployments found. Please deploy Cloud Foundry first."
        elsif names.size == 1
          names.first
        else
          choose do |menu|
            menu.prompt = 'Choose target Cloud Foundry deployment: '
            names.each do |name|
              menu.choice(name) { name }
            end
          end
        end
      end

      # return list of selected docker services; or nil to install all services
      def choose_one_or_all_cf_services
        templates = Dir["templates/services/*.yml"].reject {|f| File.basename(f) == "all.yml"}
        services = templates.map do |path|
          template = YAML.load_file(path)
          label = template["properties"]["cfcontainersbroker"]["services"].first["name"]
          name = template["properties"]["cfcontainersbroker"]["services"].first["metadata"]["displayName"]
          [label, name]
        end
        choose do |menu|
          menu.prompt = 'Choose a service (or ALL): '
          menu.choice("ALL") { nil }
          services.each do |label, name|
            menu.choice(name) { [label] }
          end
        end
      end
  end
end
