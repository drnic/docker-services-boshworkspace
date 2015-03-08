require "bosh/cloud_deployment"
require "bosh/cloud_deployment/aws"

describe Bosh::CloudDeployment::AWS do
  subject { Bosh::CloudDeployment::AWS.new }
  it { expect(subject.cpi).to eq "aws" }
  it "subnet already being used"
  it "no deployments using subnet"
end
