require "bosh/cloud_deployment/base"
class Bosh::CloudDeployment::AWS < Bosh::CloudDeployment::Base
  attr_reader :security_groups
  attr_reader :subnet_id
  attr_reader :instance_type

  def cpi; "aws"; end

  def setup
    setup_cf
    if subnet = cf_using_subnets?
      @security_groups = subnet["subnets"].first["cloud_properties"]["security_groups"]
      @security_groups = [security_groups] if security_groups.is_a?(String)
      puts "Security groups: #{security_groups.join(', ')}"
      @subnet_id = ask("Subnet ID: ")
      @instance_type = ask("Instance type: ")
    end

    persistent_disk = ask("Persistent disk volume size (Gb): ").to_i * 1024
    persistent_disk = 4096 if persistent_disk < 4096
  end

  def manifest_stub
    stub = common_stub.merge({
      "stemcells" => [{
        "name" => "bosh-aws-xen-ubuntu-trusty-go_agent",
        "version" => 2865
      }],
      "templates" => [
        "docker-deployment.yml",
        "docker-properties.yml",
        "docker-jobs.yml",
        "docker-aws-vpc.yml",
      ],
    })
    stub["meta"]["subnet_ids"] = {
      "docker" => subnet_id
    }
    stub["meta"]["security_groups"] = security_groups
    stub["meta"]["instance_type"] = instance_type
    stub
  end
end
Bosh::CloudDeployment.register("aws", Bosh::CloudDeployment::AWS)
