require 'rails_helper'

describe SmsExpiredStartupsJob, :type => :job do
  before(:each) do
    sms_statistics_visakhapatnam = create(:db_config, key: 'sms_statistics_visakhapatnam', value: '917896543210')
    sms_statistics_kochi = create(:db_config, key: 'sms_statistics_kochi', value: '919012345678')
  end

  # Let's override environment variable values...
  before(:all) do
    APP_CONFIG[:sms_provider_url] = 'https://mobme.in'
  end

  # ...and return them to originals after the tests are run.
  after(:all) do
    APP_CONFIG[:sms_provider_url] = ENV['SMS_PROVIDER_URL']
  end

  it 'sends out two SMS-s' do
    vizag_text = 'Visakhapatnam: No. of startups with expired agreements: 0'
    kochi_text = 'Kochi: No. of startups with expired agreements: 0'

    expect(RestClient).to receive(:post).with('https://mobme.in', hash_including(text: vizag_text, msisdn: '917896543210'))
    expect(RestClient).to receive(:post).with('https://mobme.in', hash_including(text: kochi_text, msisdn: '919012345678'))

    SmsExpiredStartupsJob.perform_now
  end
end
