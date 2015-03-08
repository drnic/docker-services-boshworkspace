require "bosh/cloud_deployment/base"
class Bosh::CloudDeployment::AWS < Bosh::CloudDeployment::Base
  attr_reader :security_groups
  attr_reader :subnet_id
  attr_reader :instance_type
  attr_reader :persistent_disk

  def cpi; "aws"; end

  def setup
    setup_cf
    if subnet = cf_using_subnets?
      @security_groups = subnet["subnets"].first["cloud_properties"]["security_groups"]
      @security_groups = [security_groups] if security_groups.is_a?(String)
      puts "Security groups: #{security_groups.join(', ')}"
      @instance_type = ask("Instance type: ")
      @subnet_id = ask("Subnet ID: ")
      clashing_deployments = lookup_deployments_using_same_subnet
    end

    @persistent_disk = ask("Persistent disk volume size (Gb): ").to_i * 1024
    @persistent_disk = 4096 if persistent_disk < 4096
  end

  def manifest_stub
    stub = common_stub.merge({
      "templates" => [
        "docker-deployment.yml",
        "docker-properties.yml",
        "docker-jobs.yml",
        "docker-aws-vpc.yml",
      ],
    })
    add_service_templates(stub)

    stub["meta"]["persistent_disk"] = persistent_disk
    stub["meta"]["subnet_ids"] = {
      "docker" => subnet_id
    }
    stub["meta"]["security_groups"] = security_groups
    stub["meta"]["instance_type"] = instance_type
    stub
  end

  def deployment_subnets(deployment_name)
    list = []
    if manifest = get_deployment_manifest(deployment_name)
      manifest["networks"].each do |network|
        # networks:
        # - name: cf1
        #   subnets:
        #   - cloud_properties:
        #       availability_zone: us-west-2a
        #       security_groups: cf-0-vpc-fa2f849f
        #       subnet: subnet-5351d336
        if network["subnets"] && (subnets = network["subnets"])
          subnets.each do |subnet|
            list << subnet["cloud_properties"]["subnet"]
          end
        end
      end
      list
    end
  end

  # return list of deployments using specific subnet
  def deployments_using_subnet(subnet_id)
    clashing_deployment_names = existing_deployment_names(true).select do |name|
      subnets = deployment_subnets(name)
      subnets.include?(subnet_id)
    end
  end
end
Bosh::CloudDeployment.register("aws", Bosh::CloudDeployment::AWS)
