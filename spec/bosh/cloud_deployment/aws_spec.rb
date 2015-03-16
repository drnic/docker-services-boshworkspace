require "bosh/cloud_deployment"
require "bosh/cloud_deployment/aws"

describe Bosh::CloudDeployment::AWS do
  subject { Bosh::CloudDeployment::AWS.new }
  before do
    subject.director_client = instance_double("Bosh::Cli::Client::Director")
  end

  it { expect(subject.cpi).to eq "aws" }

  describe "subnets" do
    describe "with cf-aws-tiny" do
      before do
        cf_manifest = YAML.load_file(spec_asset("cf-aws-tiny.yml"))
        expect(subject).to receive(:get_deployment_manifest).with("cf").and_return(cf_manifest)
      end
      it "discovers subnets from CF manifest" do
        expect(subject.deployment_subnets("cf")).to eq(%w[subnet-5351d336 subnet-0061c177 subnet-5251d337])
      end
      it "subnet already being used" do
        expect(subject).to receive(:existing_deployment_names).and_return(["cf"])
        expect(subject.deployments_using_subnet("subnet-new")).to eq []
      end
      it "no deployments using subnet" do
        expect(subject).to receive(:existing_deployment_names).and_return(["cf"])
        expect(subject.deployments_using_subnet("subnet-5351d336")).to eq ["cf"]
      end

      it "subnet_from_deployment finds subnet" do
        subnet = subject.subnet_from_deployment("subnet-5351d336", "cf")
        expect(subnet).to_not be_nil
        expect(subnet["range"]).to eq "10.10.3.0/24"
      end
      it "subnet_from_deployment does not find subnet" do
        subnet = subject.subnet_from_deployment("subnet-unknown", "cf")
        expect(subnet).to be_nil
      end
    end

    describe "deployment_subnets" do
      it "discovers subnets from cf-tiny-aws manifest" do
        cf_manifest = YAML.load_file(spec_asset("cf-aws-tiny.yml"))
        expect(subject).to receive(:get_deployment_manifest).with("cf").and_return(cf_manifest)
        expect(subject.deployment_subnets("cf")).to eq(%w[subnet-5351d336 subnet-0061c177 subnet-5251d337])
      end
      it "discovers subnets from cf-aws-dedicated-v194 manifest" do
        cf_manifest = YAML.load_file(spec_asset("cf-aws-dedicated-v194.yml"))
        expect(subject).to receive(:get_deployment_manifest).with("cf").and_return(cf_manifest)
        expect(subject.deployment_subnets("cf")).to eq(%w[subnet-76d8045d subnet-dda036aa])
      end
      it "discovers subnets from cf-redis-aws manifest" do
        cf_manifest = YAML.load_file(spec_asset("cf-redis-aws.yml"))
        expect(subject).to receive(:get_deployment_manifest).with("redis").and_return(cf_manifest)
        expect(subject.deployment_subnets("redis")).to eq(%w[subnet-55d8047e])
      end
    end

    it "splits reused subnets into two reserved ranges" do
      first_range = [IPAddr.new("10.10.5.0"), IPAddr.new("10.10.5.15")]
      last_range = [IPAddr.new("10.10.5.32"), IPAddr.new("10.10.5.255")]
      ranges = subject.to_subnet_reserved(first_range, last_range)
      expect(ranges.size).to eq 2
      expect(ranges.first).to eq("10.10.5.2-10.10.5.15")
      expect(ranges.last).to eq("10.10.5.32-10.10.5.254")
    end
  end

  it "existing_deployment_names" do
    expect(subject.director_client).to receive(:list_deployments).and_return([{"name" => "foo"}, {"name" => "bar"}]).twice
    subject.deployment_name = "bar"
    expect(subject.existing_deployment_names(false)).to eq(%w[foo bar])
    expect(subject.existing_deployment_names(true)).to eq(%w[foo])
  end
end
