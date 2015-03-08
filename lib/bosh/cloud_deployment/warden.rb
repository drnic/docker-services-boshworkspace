require "bosh/cloud_deployment/base"
class Bosh::CloudDeployment::Warden < Bosh::CloudDeployment::Base
  def cpi; "warden"; end

  def setup
    setup_cf
  end

  def manifest_stub
    common_stub.merge({
      "stemcells" => [{
        "name" => "bosh-warden-boshlite-ubuntu-trusty-go_agent",
        "version" => 389
      }],
      "templates" => [
        "docker-deployment.yml",
        "docker-properties.yml",
        "docker-jobs.yml",
        "docker-warden.yml",
      ]
    })
  end
end
Bosh::CloudDeployment.register("warden", Bosh::CloudDeployment::Warden)
