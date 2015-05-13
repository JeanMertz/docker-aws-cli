require 'spec_helper'

aws_cli_version = '1.7.26'

describe RSpec.configuration.docker_image_name do
  describe file('/usr/bin/aws') do
    it { is_expected.to be_executable }
  end

  describe command('/usr/bin/aws --version') do
    its(:stderr) { is_expected.to include("aws-cli/#{aws_cli_version}") }
  end
end
