require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

describe 'AEM Publish Daemon' do
  it 'is listening on port 4503' do
    expect(port(4503)).to be_listening
  end

  it 'has a running service of aem-publish' do
    expect(service('aem-publish')).to be_running
  end
end
