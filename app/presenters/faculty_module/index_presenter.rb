module FacultyModule
  class IndexPresenter < ApplicationPresenter
    def coaches_subheading
      @coaches_subheading ||= SchoolString::CoachesIndexSubheading.for(current_school)
    end
  end
end
