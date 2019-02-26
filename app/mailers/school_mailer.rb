class SchoolMailer < ActionMailer::Base
  include Roadie::Rails::Mailer

  layout 'mail/school'

  helper_method :host_options

  protected

  def host_options
    {
      host: @school.domains.primary.fqdn,
      protocol: 'https'
    }
  end

  def from
    "#{@school.name} <noreply@pupilfirst.com>"
  end

  def roadie_options_for_school
    roadie_options.combine(url_options: host_options)
  end
end
