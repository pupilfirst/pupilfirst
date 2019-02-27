class FooterPresenter < ApplicationPresenter
  def student?
    true
  end

  def links
    [
      ['Home', '/']
    ]
  end

  def school_name
    @school_name ||= current_school.present? ? current_school.name : 'PupilFirst'
  end

  def logo?
    current_school.logo_on_dark_bg.attached?
  end

  def logo_url
    view.url_for(current_school.logo_variant(:thumb, bg: :dark))
  end

  private

  def current_school
    @current_school ||= view.current_school
  end
end
