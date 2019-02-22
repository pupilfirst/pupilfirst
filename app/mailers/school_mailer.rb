class SchoolMailer < ActionMailer::Base
  include Roadie::Rails::Mailer

  layout 'mail/school'

  helper_method :host_options

  protected

  def host_options
    {
      host: @school.domains.first.fqdn,
      protocol: 'https'
    }
  end

  def from(school)
    "#{school.name} <noreply@pupilfirst.com>"
  end

  def roadie_options_for(school)
    roadie_options.combine(url_options: { protocol: 'https', host: school.domains.first.fqdn })
  end
end
