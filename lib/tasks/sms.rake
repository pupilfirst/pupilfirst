namespace :sms do
  desc 'Send out statistics as SMS to configured numbers.'
  task statistics: [:environment] do
    APP_CONFIG[:sms_statistics_to].each do |msisdn|
      statistics_sms = "Total incubation requests: #{5281 + Startup.incubation_requested.count}\n" +
        "Incubated startups: #{Startup.agreement_live.count}\n" +
        "Community: #{User.count}\n" +
        "Student entrepreneurs: #{User.student_entrepreneurs.count}\n" +
        "On Campus: #{Startup.physically_incubated.count}\n" +
        "Incubated startups (cumulative): #{849 + Startup.agreement_signed_filtered.count}\n"

      RestClient.post(APP_CONFIG[:sms_provider_url], text: statistics_sms, msisdn: msisdn)
    end
  end
end
