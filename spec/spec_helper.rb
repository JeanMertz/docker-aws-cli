require 'archive/tar/minitar'
require 'docker'
require 'excon'
require 'serverspec'

set :backend, :docker

Excon.defaults[:ssl_verify_peer] = false

Docker.options = { read_timeout: 600, write_timeout: 600 }

RSpec.configure do |config|
  image_name = File.basename(File.dirname(__dir__)).sub('docker-', '')
  config.add_setting :docker_image_name, default: "blendle/#{image_name}:test"

  config.before(:suite) do
    puts 'preparing new Docker image for testing...'

    files = Dir.glob('*').reject { |f| f.include?('vendor') }
    tmp   = Tempfile.new(SecureRandom.urlsafe_base64)

    Archive::Tar::Minitar.pack(files, tmp, true)
    tar = File.new(tmp.path, 'r')

    image = Docker::Image.build_from_tar(tar, t: config.docker_image_name)
    config.docker_image = image.id
  end

  config.docker_container_create_options = {
    'Entrypoint' => ['/usr/bin/tail'],
    'Cmd' => ['-f', '/dev/null']
  }
end

Docker.options = { read_timeout: 60, write_timeout: 60 }
