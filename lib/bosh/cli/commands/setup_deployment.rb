module Bosh::Cli::Command
  class SetupDeployment < Base
    usage "setup deployment"
    desc "Prompt user to setup Docker services prior to deployment"
    def setup_deployment(cf_deployment_name=nil)
      # - select target cf deployment (bosh target consul - has something like this)
      # - download manifest
      #   - get CC URL
      #   - get NATS servers + credentials
      #   - get DEA/runner security group (as the default SG)
      cf_deployment_name ||= prompt_for_deployment
      unless cf_manifest = director.get_deployment(cf_deployment_name)["manifest"]
        err "Deployment '#{cf_deployment_name}' has not completed successfully yet."
      end
      cf = YAML.load(cf_manifest)
      unless cc_api_uri = cf["properties"]["cc"] && cf["properties"]["cc"]["srv_api_uri"]
        err "Deployment '#{cf_deployment_name}' is not Cloud Foundry. Missing properties.cc.srv_api_uri property."
      end
      puts "CF API: #{cc_api_uri}"
    end


    private
      def prompt_for_deployment
        names = director.list_deployments.map { |deployment| deployment["name"] }
        if names.size == 0
          err "No deployments found. Please deploy Cloud Foundry first."
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
  end
end
