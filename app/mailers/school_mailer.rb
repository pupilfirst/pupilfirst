class SchoolMailer < ActionMailer::Base
  include Roadie::Rails::Mailer

  layout 'mail/school'

  protected

  def roadie_options_for(school)
    roadie_options.combine(
      url_options: {
        host: "https://#{school.domains.first.fqdn}",
        from: "#{school.name} <noreply@pupilfirst.com>"
      }
    )
  end
end
