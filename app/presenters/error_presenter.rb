class ErrorPresenter < ApplicationPresenter
  def page_title
    "Oops! | #{site_name}"
  end

  def site_name
    @site_name ||= current_school.present? ? current_school.name : 'Pupilfirst'
  end

  def contact_email
    @contact_email ||= begin
      if current_school.present?
        SchoolString::EmailAddress.for(current_school)
      end
    end
  end

  def school_has_icon?
    return true if current_school.blank?

    current_school.icon.attached?
  end

  def school_icon_url
    if current_school.present?
      view.url_for(current_school.icon_variant(:thumb))
    else
      view.image_path('shared/pupilfirst-icon.svg')
    end
  end
end
