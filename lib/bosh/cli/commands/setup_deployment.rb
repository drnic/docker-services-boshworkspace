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
    option '--deployment-name NAME', 'Name this deployment. Default: cf-containers-broker-<services>'
    option '--cf-deployment-name NAME', 'Select Cloud Foundry deployment name, instead of menu'
    option '--debug', 'Show extra debug information on decisions made'
    def setup_deployment
      cf_deployment_name = options[:cf_deployment_name]
      cf_deployment_name ||= prompt_for_deployment("cf")

      say "Looking up '#{cf_deployment_name}'..."
      unless cf_manifest = director.get_deployment(cf_deployment_name)["manifest"]
        err "Deployment '#{cf_deployment_name}' has not completed successfully yet."
      end
      @cf = YAML.load(cf_manifest)

      if cf_services = choose_one_or_all_cf_services
        default_deployment_name = "cf-containers-broker-#{cf_services.join('-')}"
      else
        default_deployment_name = "cf-containers-broker"
      end

      deployment_name = options[:deployment_name]
      deployment_name ||= default_deployment_name

      cloud_deployment = Bosh::CloudDeployment.cloud(cpi)
      cloud_deployment.director_client = director
      cloud_deployment.director_uuid = director.uuid
      cloud_deployment.cf = @cf
      cloud_deployment.deployment_name = deployment_name
      cloud_deployment.cf_services = cf_services
      cloud_deployment.password = generate_password
      cloud_deployment.debug = options[:debug]
      cloud_deployment.setup


      deployment_stub_file = "deployments/#{cloud_deployment.deployment_name}.yml"
      File.open(deployment_stub_file, "w") do |f|
        f << cloud_deployment.manifest_stub.to_yaml
      end
      sh "bosh deployment #{deployment_stub_file}"
      sh "bosh deploy"

      say "Docker images being fetched. Polling until broker alive...".make_green
      require "net/http"
      require "uri"

      user, pass = cloud_deployment.username, cloud_deployment.password

      http = Net::HTTP.new(cloud_deployment.broker_api_hostname)
      response = nil
      until response && (response.code.to_i < 400)
        sleep(5); print "."
        request = Net::HTTP::Get.new("/v2/catalog")
        request.basic_auth(user, pass)
        response = http.request(request)
      end
      say "complete.".make_green

      broker_uri = cloud_deployment.broker_api_uri
      say "Login to Cloud Foundry as an admin and register your broker with:".make_green
      say "cf create-service-broker #{deployment_name} #{user} #{pass} #{broker_uri}"
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

      def generate_password
        (0...20).map { ('a'..'z').to_a[rand(26)] }.join
      end
  end
end
