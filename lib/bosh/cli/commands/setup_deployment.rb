module Bosh::Cli::Command
  class SetupDeployment < Base
    attr_reader :cf

    usage "setup deployment"
    desc "Prompt user to setup Docker services prior to deployment"
    def setup_deployment(cf_deployment_name=nil)
      # - select target cf deployment (bosh target consul - has something like this)
      # - download manifest
      #   - get CC URL
      #   - get NATS servers + credentials
      #   - get DEA/runner security group (as the default SG)
      cf_deployment_name ||= prompt_for_deployment("cf")

      say "Looking up '#{cf_deployment_name}'..."
      unless cf_manifest = director.get_deployment(cf_deployment_name)["manifest"]
        err "Deployment '#{cf_deployment_name}' has not completed successfully yet."
      end
      @cf = YAML.load(cf_manifest)

      unless cc_api_uri = cf["properties"]["cc"] && cf["properties"]["cc"]["srv_api_uri"]
        err "Deployment '#{cf_deployment_name}' is not Cloud Foundry. Missing properties.cc.srv_api_uri property."
      end
      unless system_domain = cf["properties"]["system_domain"]
        err "Deployment '#{cf_deployment_name}' is not Cloud Foundry. Missing properties.system_domain property."
      end
      unless nats = cf["properties"]["nats"]
        err "Deployment '#{cf_deployment_name}' is not Cloud Foundry. Missing properties.nats property."
      end
      # nats:
      #   machines:
      #   - 10.244.0.6
      #   password: nats
      #   port: 4222
      #   user: nats

      say "CF API: #{cc_api_uri}"
      say "System domain: #{system_domain}"
      say "NATS servers: #{nats["machines"].join(', ')}"

      # TODO - generate this hostname, to allow docker-service to be deployed multiple times
      broker_api_hostname = "http://cf-containers-broker.#{system_domain}"
      say "Broker API: #{broker_api_hostname}"

      puts "CPI: #{cpi}"
      if cpi == "aws" || cpi == "openstack"
        if subnet = cf_using_subnets?
          security_groups = subnet["subnets"].first["cloud_properties"]["security_groups"]
          security_groups = [security_groups] if security_groups.is_a?(String)
          puts "Security groups: #{security_groups.join(', ')}"
          subnet_id = ask("Subnet ID for docker service: ")
        end
      end
      # TODO: abstract this into handler classes based on CPI
      # AWS/OpenStack
      # - select subnet (if CF deployment uses subnets)
      # - get security group for the runner/dea_next jobs
      # - choose an instance type (more epheral disk the better)
      # VSphere:
      # - choose RAM/CPU/Disk for instance
      # All except warden: choose persistent disk size (to be shared amongst all services)

      # Next: select which services to include (fewer = less docker images to fetch)
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

      # return version of stemcell used within Cloud Foundry deployment
      def cf_stemcell_version
        cf["resource_pools"].first["stemcell"]["version"]
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

      # returns subnet info if any CF deployment's networks are using subnets; else nil
      def cf_using_subnets?
        cf["networks"].find {|network| network["subnets"]}
      end
  end
end
