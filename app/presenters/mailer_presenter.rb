class MailerPresenter < ApplicationPresenter
  def initialize(view_context, school, course: nil)
    @school = school
    @course = course
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

  def course_cover?
    @course_cover ||= !!@course&.cover&.attached?
  end

  def course_cover_url
    view.url_for(@course.cover)
  end

  def hero_title_classes
    default = "mailer-body__hero-title"
    course_cover? ? default + " mailer-body__hero-title--dark" : default
  end

  def hero_classes
    default = "mailer-body__hero"
    course_cover? ? default + " mailer-body__hero--dark" : default
  end

  def button_classes
    default = "mailer-button"
    course_cover? ? default + " mailer-button--dark" : default
  end
end
