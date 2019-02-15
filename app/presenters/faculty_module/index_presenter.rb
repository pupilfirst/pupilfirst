module FacultyModule
  class IndexPresenter < ApplicationPresenter
    def coaches_subheading
      @coaches_subheading ||= view.current_school.school_strings.find_by(key: SchoolString::KEYS[:coaches_index_subheading])&.value
    end
  end
end
