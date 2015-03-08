require "bosh/cloud_deployment/base"
class Bosh::CloudDeployment::Warden < Bosh::CloudDeployment::Base
  def cpi; "warden"; end

  def setup
    setup_cf
  end

  def manifest_stub
    stub = common_stub.merge({
      "templates" => [
        "docker-deployment.yml",
        "docker-properties.yml",
        "docker-jobs.yml",
        "docker-warden.yml",
      ]
    })
    add_service_templates(stub)
    stub
  end
end
Bosh::CloudDeployment.register("warden", Bosh::CloudDeployment::Warden)
