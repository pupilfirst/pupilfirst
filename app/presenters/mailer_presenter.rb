class MailerPresenter < ApplicationPresenter
  def initialize(view_context, school)
    @school = school
    raise '@school cannot be unassigned' if @school.blank?

    super(view_context)
  end

  def school_name
    @school.name
  end

  def school_url
    "https://#{@school.domains.primary.fqdn}"
  end

  def logo?
    @school.logo_on_light_bg.attached?
  end

  def logo
    view.image_tag(view.url_for(@school.logo_variant(:mid)), class: 'mailer-head__logo-img')
  end
end
