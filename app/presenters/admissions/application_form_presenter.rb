module Admissions
  class ApplicationFormPresenter < ApplicationPresenter
    def college_collection(form)
      if selected_college(form).present?
        [selected_college(form)]
      else
        [OpenStruct.new(name: "My college isn't listed", id: 'other')]
      end
    end

    def selected_college(form)
      if form.object.college_id == 'other'
        OpenStruct.new(name: "My college isn't listed", id: 'other')
      else
        form.object.college_id.present? ? College.find_by(id: form.object.college_id) : nil
      end
    end
  end
end
