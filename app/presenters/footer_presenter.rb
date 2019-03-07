class FooterPresenter < ApplicationPresenter
  def student?
    true
  end

  def nav_links
    footer_links = [{ title: 'Home', url: '/' }]

    return footer_links if current_school.blank?

    custom_links = SchoolLink.where(
      school: current_school,
      kind: SchoolLink::KIND_FOOTER
    ).map { |sl| { title: sl.title, url: sl.url } }

    footer_links + custom_links
  end

  def social_links
    @social_links ||= SchoolLink.where(
      school: current_school,
      kind: SchoolLink::KIND_SOCIAL
    ).map { |sl| { title: sl.title, url: sl.url } }
  end

  def school_name
    @school_name ||= current_school.present? ? current_school.name : 'PupilFirst'
  end

  def logo?
    return true if current_school.blank?

    current_school.logo_on_dark_bg.attached?
  end

  def logo_url
    if current_school.present?
      view.url_for(current_school.logo_variant(:mid, background: :dark))
    else
      view.image_url('shared/pupilfirst-logo-white.svg')
    end
  end

  # TODO: Write a better way to decide which icon to present
  def social_icon(url)
    %w[facebook twitter instagram youtube].each do |key|
      if key.in?(url)
        return "fa-#{key}"
      end
    end

    'fa-users'
  end

  def address
    @address ||= begin
      if current_school.present?
        raw_address = SchoolString::Address.for(current_school)
        Kramdown::Document.new(raw_address).to_html if raw_address.present?
      else
        view.t('presenters.footer.address_html')
      end
    end
  end

  def email_address
    @email_address ||= begin
      if current_school.present?
        SchoolString::EmailAddress.for(current_school)
      else
        view.t('presenters.footer.email_address')
      end
    end
  end

  def privacy_policy?
    return true if current_school.blank?

    SchoolString::PrivacyPolicy.saved?(current_school)
  end

  def terms_of_use?
    return true if current_school.blank?

    SchoolString::TermsOfUse.saved?(current_school)
  end
end
