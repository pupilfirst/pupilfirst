class SmsExpiredStartupAgreementsJob < ActiveJob::Base
  def perform
    msisdns_visakhapatnam = DbConfig.find_by(key: 'sms_statistics_visakhapatnam').value.split(',')
    msisdns_kochi = DbConfig.find_by(key: 'sms_statistics_kochi').value.split(',')

    kochi_expired_count = Startup.kochi.agreement_expired.count
    vizag_expired_count = Startup.visakhapatnam.agreement_expired.count

    message = '%{location}: No. of startups with expired agreements: %{count}'

    msisdns_kochi.each do |msisdn|
      RestClient.post(APP_CONFIG[:sms_provider_url], text: message % { location: 'Kochi', count: kochi_expired_count }, msisdn: msisdn)
    end

    Rails.llog.info event: :sms_expired_startup_agreements, incubation_location: 'kochi'

    msisdns_visakhapatnam.each do |msisdn|
      RestClient.post(APP_CONFIG[:sms_provider_url], text: message % { location: 'Visakhapatnam', count: vizag_expired_count }, msisdn: msisdn)
    end

    Rails.llog.info event: :sms_expired_startup_agreements, incubation_location: 'visakhapatnam'
  end
end
