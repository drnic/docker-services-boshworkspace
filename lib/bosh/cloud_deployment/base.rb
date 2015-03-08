class Bosh::CloudDeployment::Base
  attr_accessor :debug
  attr_accessor :cf
  attr_accessor :director_client
  attr_accessor :director_uuid
  attr_accessor :deployment_name
  attr_accessor :cf_services

  attr_reader :cc_api_uri
  attr_reader :system_domain
  attr_reader :nats
  attr_reader :broker_api_hostname

  def setup_cf
    if debug
      puts "Director UUID: #{director_uuid}"
      puts "CPI: #{cpi}"
    end

    unless @cc_api_uri = cf["properties"]["cc"] && cf["properties"]["cc"]["srv_api_uri"]
      err "Deployment '#{cf_deployment_name}' is not Cloud Foundry. Missing properties.cc.srv_api_uri property."
    end
    unless @system_domain = cf["properties"]["system_domain"]
      err "Deployment '#{cf_deployment_name}' is not Cloud Foundry. Missing properties.system_domain property."
    end
    unless @nats = cf["properties"]["nats"]
      err "Deployment '#{cf_deployment_name}' is not Cloud Foundry. Missing properties.nats property."
    end

    # TODO - generate this hostname, to allow docker-service to be deployed multiple times
    @broker_api_hostname = "cf-containers-broker.#{system_domain}"
    if debug
      say "Broker API: #{broker_api_hostname}"
      say "CF API: #{cc_api_uri}"
      say "System domain: #{system_domain}"
      say "NATS servers: #{nats["machines"].join(', ')}"
    end
  end

  # returns subnet info if any CF deployment's networks are using subnets; else nil
  def cf_using_subnets?
    cf["networks"].find {|network| network["subnets"]}
  end

  # return name of stemcell used within Cloud Foundry deployment
  def cf_stemcell_name
    cf["resource_pools"].first["stemcell"]["name"]
  end

  # return version of stemcell used within Cloud Foundry deployment
  def cf_stemcell_version
    cf["resource_pools"].first["stemcell"]["version"]
  end

  def common_stub
    {
      "name" => deployment_name,
      "director_uuid" => director_uuid,
      "releases" => [
        {
          "name" => "docker",
          "version" => "latest",
          "git" => "https://github.com/cf-platform-eng/docker-boshrelease.git"
        }
      ],
      "stemcells" => [{
        "name" => cf_stemcell_name,
        "version" => cf_stemcell_version
      }],
      "templates" => nil,
      "meta" => {
        "cfcontainersbroker" => {
          "cc_api_uri" => cc_api_uri,
          "external_host" => broker_api_hostname,
        },
        "nats" => {
          "machines" => nats["machines"],
          "port" => nats["port"],
          "user" => nats["user"],
          "password" => nats["password"],
        },
      }
    }
  end

  def add_service_templates(stub)
    if cf_services
      cf_services.each do |service|
        stub["templates"] << "services/#{service}.yml"
      end
    else
      stub["templates"] << "services/all.yml"
    end
  end

  # return existing/running deployments; set +ignore_self+ to true to ignore this deployment
  def existing_deployment_names(ignore_self=false)
    all = director_client.list_deployments.map { |deployment| deployment["name"] }
    if ignore_self
      all - [deployment_name]
    else
      all
    end
  end

  # loads deployment manifest; returns nil if deployment missing or not completed
  def get_deployment_manifest(deployment_name)
    if manifest_yaml = director_client.get_deployment(deployment_name)["manifest"]
      manifest = YAML.load(manifest_yaml)
    else
      nil
    end
  end
end
