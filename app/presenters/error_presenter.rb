class ErrorPresenter < ApplicationPresenter
  def page_title
    "Oops! | #{site_name}"
  end

  def site_name
    @site_name ||= current_school.present? ? current_school.name : "Pupilfirst"
  end

  def contact_email
    @contact_email ||=
      begin
        if current_school.present?
          SchoolString::EmailAddress.for(current_school)
        end
      end
  end

  def school_icon(background)
    icon = background == :dark ? :icon_on_dark_bg : :icon_on_light_bg

    if current_school.present? && current_school.public_send(icon).attached?
      icon_url =
        view.rails_public_blob_url(
          current_school.icon_variant(:thumb, background: background)
        )
      view.image_tag(icon_url, class: "w-12 #{icon}")
    elsif current_school.present?
      view.content_tag(:span, current_school.name, class: " #{icon}")
    else
      view.image_tag("shared/pupilfirst-icon.svg", class: "w-12 #{icon}")
    end
  end
end
