namespace :sms do
  desc 'Send out statistics as SMS to configured numbers.'
  task statistics: [:environment] do
    statistics_sms = "Total incubation requests: #{5281 + Startup.incubation_requested.count}\n" +
      "Incubated startups: #{Startup.agreement_live.count}\n" +
      "Community: #{User.count}\n" +
      "Student entrepreneurs: #{User.student_entrepreneurs.count}\n" +
      "On Campus: #{Startup.physically_incubated.count}\n" +
      "Incubated startups (cumulative): #{849 + Startup.agreement_signed_filtered.count}\n"

    startups_at_visakhapatnam = Startup.where(incubation_location: Startup::INCUBATION_LOCATION_VISAKHAPATNAM)

    statistics_for_andhra = "\nAndra statistics follow\n" +
      "Total incubation Requests: #{startups_at_visakhapatnam.incubation_requested.count}"
      "Incubated startups: #{startups_at_visakhapatnam.agreement_live.count}" +
      "On Campus: #{startups_at_visakhapatnam.physically_incubated.count}" +
      "Incubated startups (cumulative): #{startups_at_visakhapatnam.agreement_signed.count}"

    statistics_sms += statistics_for_andhra

    APP_CONFIG[:sms_statistics_to].each do |msisdn|
      RestClient.post(APP_CONFIG[:sms_provider_url], text: statistics_sms, msisdn: msisdn)
    end
  end
end
