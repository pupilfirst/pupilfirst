module Layouts
  class ApplicationPresenter < ::ApplicationPresenter
    def school_name
      @school_name ||= current_school.present? ? current_school.name : 'PupilFirst'
    end

    def logo?
      return true if current_school.blank?

      current_school.logo_on_light_bg.attached?
    end

    def logo_url
      if current_school.blank?
        view.image_url('mailer/pupilfirst-logo.png')
      else
        view.url_for(current_school.logo_variant(:mid))
      end
    end

    def meta_description
      @meta_description ||= Layouts::TailwindPresenter.new(view).meta_description
    end
  end
end
