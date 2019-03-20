module Schools
  module FacultyModule
    class SchoolIndexPresenter < ApplicationPresenter
      def initialize(view_context, school)
        super(view_context)

        @school = school
      end

      def faculty
        Faculty.where(school: @school).includes(:user, image_attachment: :blob)
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
            email: faculty.user.email,
            title: faculty.title,
            imageUrl: faculty.image_or_avatar_url,
            linkedinUrl: faculty.linkedin_url,
            public: faculty.public,
            connectLink: faculty.connect_link,
            notifyForSubmission: faculty.notify_for_submission,
            imageFileName: faculty.image_filename
          }
        end
      end
    end
  end
end
