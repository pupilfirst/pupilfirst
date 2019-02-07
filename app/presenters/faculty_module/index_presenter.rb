module FacultyModule
  class IndexPresenter < ApplicationPresenter
    def coaches_subheading
      view.current_school.school_strings.find_by(key: SchoolString::KEY_COACHES_INDEX_SUBHEADING)&.value
    end
  end
end
