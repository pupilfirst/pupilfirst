module Schools
  module FacultyModule
    class SchoolIndexPresenter < ApplicationPresenter
      def initialize(view_context, school)
        super(view_context)

        @school = school
      end

      def faculty
        Faculty.where(school: @school)
      end

      def react_props
        { coaches: faculty_details, schoolId: @school.id, authenticityToken: view.form_authenticity_token }
      end

      private

      def faculty_details
        faculty.map do |faculty|
          {
            id: faculty.id,
            name: faculty.name,
            imageUrl: faculty.image_or_avatar_url,
            email: faculty.user.email,
            title: faculty.title
          }
        end
      end
    end
  end
end
