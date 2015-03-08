require "bosh/cloud_deployment"
require "bosh/cloud_deployment/warden"

describe Bosh::CloudDeployment::Warden do
  subject { Bosh::CloudDeployment::Warden.new }
  it { expect(subject.cpi).to eq "warden" }
end
