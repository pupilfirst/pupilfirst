namespace :sms do
  desc 'Send out statistics as SMS to configured numbers.'
  task statistics: [:environment] do
    statistics_total = "Total statistics\n" +
      "Total incubation requests: #{5281 + Startup.incubation_requested.count}\n" +
      "Incubated startups: #{Startup.agreement_live.count}\n" +
      "Community: #{User.count}\n" +
      "Student entrepreneurs: #{User.student_entrepreneurs.count}\n" +
      "On Campus: #{Startup.physically_incubated.count}\n" +
      "Incubated startups (cumulative): #{849 + Startup.agreement_signed_filtered.count}\n"

    startups_at_visakhapatnam = Startup.where(incubation_location: Startup::INCUBATION_LOCATION_VISAKHAPATNAM)

    statistics_for_visakhapatnam = "Visakhapatnam statistics\n" +
      "Total incubation Requests: #{startups_at_visakhapatnam.incubation_requested.count}\n" +
      "Incubated startups: #{startups_at_visakhapatnam.agreement_live.count}\n" +
      "On Campus: #{startups_at_visakhapatnam.physically_incubated.count}\n" +
      "Incubated startups (cumulative): #{startups_at_visakhapatnam.agreement_signed.count}"

    APP_CONFIG[:sms_statistics_all].each do |msisdn|
      RestClient.post(APP_CONFIG[:sms_provider_url], text: statistics_total, msisdn: msisdn)
    end

    (APP_CONFIG[:sms_statistics_all] + APP_CONFIG[:sms_statistics_visakhapatnam]).each do |msisdn|
      RestClient.post(APP_CONFIG[:sms_provider_url], text: statistics_for_visakhapatnam, msisdn: msisdn)
    end
  end
end
