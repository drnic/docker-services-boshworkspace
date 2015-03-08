class Bosh::CloudDeployment::Base
  attr_accessor :cf
  attr_accessor :director_uuid
  attr_accessor :deployment_name

  attr_reader :cc_api_uri
  attr_reader :system_domain
  attr_reader :nats
  attr_reader :broker_api_hostname

  def setup_cf
    puts "Director UUID: #{director_uuid}"
    puts "CPI: #{cpi}"

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
    @broker_api_hostname = "http://cf-containers-broker.#{system_domain}"
    say "Broker API: #{broker_api_hostname}"


    say "CF API: #{cc_api_uri}"
    say "System domain: #{system_domain}"
    say "NATS servers: #{nats["machines"].join(', ')}"
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
      "stemcells" => nil,
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
end
