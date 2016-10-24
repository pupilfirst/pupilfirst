shared_context 'allow_temporary_net_connect' do
  before :all do
    WebMock.allow_net_connect!
  end

  after :all do
    WebMock.disable_net_connect!
  end
end
