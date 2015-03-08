class Bosh::CloudDeployment
  def self.cloud(cpi)
    require "bosh/cloud_deployment/#{cpi}"
    unless klass = @cloud_deployment_classes[cpi]
      err("'#{cpi}' templates are not yet support. Help much appreciated!")
    end
    klass.new
  end

  def self.register(name, klass)
    @cloud_deployment_classes ||= {}
    @cloud_deployment_classes[name] = klass
  end
end
