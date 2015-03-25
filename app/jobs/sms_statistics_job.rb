class SmsStatisticsJob < ActiveJob::Base
  queue_as :default

  def perform
    statistics_total = "Total statistics\n" +
      "Total incubation requests: #{Startup::LEGACY_INCUBATION_REQUESTS + Startup.incubation_requested.count}\n" +
      "Incubated startups: #{Startup.agreement_live.count}\n" +
      "Community: #{User.count}\n" +
      "Student entrepreneurs: #{User.student_entrepreneurs.count}\n" +
      "On Campus: #{Startup.physically_incubated.count}\n" +
      "Incubated startups (cumulative): #{Startup::LEGACY_STARTUPS_COUNT + Startup.agreement_signed_filtered.count}\n" + "#{Startup::SV_STATS_LINK}"

    startups_at_visakhapatnam = Startup.where(incubation_location: Startup::INCUBATION_LOCATION_VISAKHAPATNAM)

    statistics_for_visakhapatnam = "Visakhapatnam statistics\n" +
      "Total incubation Requests: #{startups_at_visakhapatnam.incubation_requested.count}\n" +
      "Incubated startups: #{startups_at_visakhapatnam.agreement_live.count}\n" +
      "On Campus: #{startups_at_visakhapatnam.physically_incubated.count}\n" +
      "Incubated startups (cumulative): #{startups_at_visakhapatnam.agreement_signed.count}\n" + "#{Startup::SV_STATS_LINK}"

    startups_at_kochi = Startup.where(incubation_location: Startup::INCUBATION_LOCATION_KOCHI)

    statistics_for_kochi = "Kochi statistics\n" +
      "Total incubation Requests: #{Startup::LEGACY_INCUBATION_REQUESTS + startups_at_kochi.incubation_requested.count}\n" +
      "Incubated startups: #{startups_at_kochi.agreement_live.count}\n" +
      "On Campus: #{startups_at_kochi.physically_incubated.count}\n" +
      "Incubated startups (cumulative): #{Startup::LEGACY_STARTUPS_COUNT + startups_at_kochi.agreement_signed_filtered.count}\n" + "#{Startup::SV_STATS_LINK}"

    msisdns_total =  DbConfig.where(key: ['sms_statistics_all', 'sms_statistics_total']).pluck(:value).join(",").split(",")
    msisdns_visakhapatnam = DbConfig.where(key: ['sms_statistics_all', 'sms_statistics_visakhapatnam']).pluck(:value).join(",").split(",")
    msisdns_kochi = DbConfig.where(key: ['sms_statistics_all', 'sms_statistics_kochi']).pluck(:value).join(",").split(",")

    msisdns_total.each do |msisdn|
      RestClient.post(APP_CONFIG[:sms_provider_url], text: statistics_total, msisdn: msisdn)
    end

    msisdns_visakhapatnam.each do |msisdn|
      RestClient.post(APP_CONFIG[:sms_provider_url], text: statistics_for_visakhapatnam, msisdn: msisdn)
    end

    msisdns_kochi.each do |msisdn|
      RestClient.post(APP_CONFIG[:sms_provider_url], text: statistics_for_kochi, msisdn: msisdn)
    end
  end
end
