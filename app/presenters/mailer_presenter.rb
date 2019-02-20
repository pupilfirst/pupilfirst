class MailerPresenter < ApplicationPresenter
  def initialize(view_context, school)
    @school = school

    super(view_context)
  end

  def school_name
    @school.present?
  end

  def school_url
    @school.domains.exist? ? "https://#{@school.domains.first.fqdn}" : "https://www.pupilfirst.com"
  end

  def logo
    if @school.present?
      view.image_tag(view.url_for(@school.logo_variant(:mid)), class: 'mailer-head__logo-img')
    else
      view.image_tag('mailer/logo-mailer.png', class: 'mailer-head__logo-img')
    end
  end
end
