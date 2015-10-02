require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

describe 'AEM Author Daemon' do
  it 'is listening on port 4502' do
    expect(port(4502)).to be_listening
  end

  it 'has a running service of aem-author' do
    expect(service('aem-author')).to be_running
  end
end
