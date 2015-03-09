require "bosh/cloud_deployment/base"
require "ipaddr"
require "core-ext/ipaddr"

class Bosh::CloudDeployment::AWS < Bosh::CloudDeployment::Base
  attr_reader :security_groups
  attr_reader :subnet_id
  attr_reader :instance_type
  attr_reader :persistent_disk
  attr_reader :compilation_workers

  def cpi; "aws"; end

  def setup
    setup_cf
    if subnet = cf_using_subnets?
      @security_groups = subnet["subnets"].first["cloud_properties"]["security_groups"]
      @security_groups = [security_groups] if security_groups.is_a?(String)
      puts "Security groups: #{security_groups.join(', ')}"
      @instance_type = ask("Instance type: ").to_s
      @persistent_disk = ask("Persistent disk volume size (Gb): ").to_i * 1024
      @persistent_disk = 4096 if persistent_disk < 4096

      @subnet_id = ask("Subnet ID: ")
      clashing_deployments = deployments_using_subnet(subnet_id)
      if clashing_deployments.size > 0
        say "Other deployments using same subnet '#{subnet_id}': #{clashing_deployments.join(', ')}".make_yellow
        existing_subnet = subnet_from_deployment(subnet_id, clashing_deployments.first)
        existing_subnet_range = IPAddr.new(existing_subnet['range'])
        ip_range = nil
        until ip_range
          begin
            say "Ctrl-C to cancel to choose alternate subnet, or...".make_yellow
            range = ask("Enter range of IPs (CIDR format: #{existing_subnet_range}/30): ").to_s
            ip_range = IPAddr.new(range)
            range_size = ip_range.to_range.to_a.size
            if range_size < minimum_total_instances
              say "#{range_size} IPs is too few. Require minimum #{minimum_total_instances} IPs".make_red
              ip_range = nil
            end
          rescue IPAddr::InvalidAddressError
            say "Invalid CIDR format. Example 10.11.12.10/30".make_red
          end
          @compilation_workers = ip_range.to_range.to_a.size - deployment_instances
          excluded_reserved_ranges = existing_subnet_range.reject(ip_range)
          say "Subnet range: #{existing_subnet['range']}"
          say "Subnet useful range: #{ip_range.to_range.first}-#{ip_range.to_range.last}"
          reserved_ranges = [
            "#{excluded_reserved_ranges.first.first}-#{excluded_reserved_ranges.first.last}",
            "#{excluded_reserved_ranges.last.first}-#{excluded_reserved_ranges.last.last}",
          ]
          say "Subnet reserved ranges: #{reserved_ranges.join(', ')}"

          ask("Confirm these subnet sub-ranges make sense. If they don't, Ctrl-C, repeat and enter valid CIDR above... ".make_yellow)
          if debug
            say "Compilation workers: #{compilation_workers}"
          end
        end
      end
    end
  end

  # minimum number of instances for deployment (including compilation workers)
  def minimum_total_instances
    deployment_instances + 1
  end

  # currently each deployment only permits 1 docker/broker instance
  def deployment_instances
    1
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


  # return subnet info from a deployment that includes it
  def subnet_from_deployment(subnet_id, deployment_name)
    if manifest = get_deployment_manifest(deployment_name)
      manifest["networks"].each do |network|
        if network["subnets"] && (subnets = network["subnets"])
          found_subnet = subnets.find do |subnet|
            next true if subnet["cloud_properties"]["subnet"] == subnet_id
          end
          return found_subnet if found_subnet
        end
      end
    end
    nil
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
