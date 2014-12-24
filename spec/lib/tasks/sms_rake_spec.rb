require 'spec_helper'

describe 'sms:statistics' do
  include_context 'rake'

  # Let's override environment variable values...
  before(:all) do
    APP_CONFIG[:sms_statistics_all] = %w(919876543210 919876543211)
    APP_CONFIG[:sms_statistics_visakhapatnam] = %w(918976543212)
    APP_CONFIG[:sms_provider_url] = 'https://mobme.in'
  end

  # ...and return them to originals after the tests are run.
  after(:all) do
    APP_CONFIG[:sms_statistics_all] = ENV['SMS_STATISTICS_ALL'].split(',')
    APP_CONFIG[:sms_statistics_visakhapatnam] = ENV['SMS_STATISTICS_VISAKHAPATNAM'].split(',')
    APP_CONFIG[:sms_provider_url] = ENV['SMS_PROVIDER_URL']
  end

  its(:prerequisites) { should include('environment') }

  it 'does something' do
    total_statistics = "Total statistics\nTotal incubation requests: 5281\nIncubated startups: 0\nCommunity: 0\nStudent entrepreneurs: 0\nOn Campus: 0\nIncubated startups (cumulative): 849\n"
    visakhapatnam_statistics = "Visakhapatnam statistics\nTotal incubation Requests: 0\nIncubated startups: 0\nOn Campus: 0\nIncubated startups (cumulative): 0"

    expect(RestClient).to receive(:post).with('https://mobme.in', hash_including(text: total_statistics, msisdn: '919876543210'))
    expect(RestClient).to receive(:post).with('https://mobme.in', hash_including(text: visakhapatnam_statistics, msisdn: '919876543210'))
    expect(RestClient).to receive(:post).with('https://mobme.in', hash_including(text: total_statistics, msisdn: '919876543211'))
    expect(RestClient).to receive(:post).with('https://mobme.in', hash_including(text: visakhapatnam_statistics, msisdn: '919876543211'))
    expect(RestClient).to receive(:post).with('https://mobme.in', hash_including(text: visakhapatnam_statistics, msisdn: '918976543212'))

    subject.invoke
  end
end