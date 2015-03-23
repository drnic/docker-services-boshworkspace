source "https://rubygems.org"

if File.directory?("../../bosh-gen")
  gem "bosh-gen", path: "../../bosh-gen"
end
if File.directory?("../../cloudfoundry/bosh-gen")
  gem "bosh-gen", path: "../../cloudfoundry/bosh-gen"
end

if File.directory?("../../cloudfoundry/bosh-workspace")
  gem "bosh-workspace", path: "../../cloudfoundry/bosh-workspace"
else
  gem "bosh-workspace"
end

gem "ipaddress"

group :test do
  gem "rspec"
end
