require "ipaddr"
require "core-ext/ipaddr"

describe IPAddr do
  it "split into two ranges around an intersecting range" do
    outer = IPAddr.new("10.10.5.0/24")
    inner = IPAddr.new("10.10.5.8/30") # 4 IPs
    left, right = outer.reject(inner)

    expect(left.first.to_s).to eq "10.10.5.0"
    expect(left.last.to_s).to eq "10.10.5.7"
    expect(right.first.to_s).to eq "10.10.5.12"
    expect(right.last.to_s).to eq "10.10.5.255"
  end

  it "removes pre-reserved IPs .0, .1, .2, .3 from AWS subnet range"
  it "removes pre-reserved last IP from AWS subnet range"
end
