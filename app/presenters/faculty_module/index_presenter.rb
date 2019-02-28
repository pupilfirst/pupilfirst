module FacultyModule
  class IndexPresenter < ApplicationPresenter
    def coaches_subheading
      @coaches_subheading ||= SchoolString.fetch(view.current_school, :coaches_index_subheading)
    end
  end
end
