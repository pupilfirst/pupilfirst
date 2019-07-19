require 'rails_helper'

describe "daily_digest" do
  include_context "rake"

  let(:service) { instance_double(DailyDigestService, execute: nil) }

  before do
    allow(DailyDigestService).to receive(:new).and_return(service)
  end

  it 'should have environment in prerequisites' do
    expect(subject.prerequisites).to include('environment')
  end

  it 'invokes DailyDigestService' do
    expect(service).to receive(:execute)
    subject.invoke
  end
end
