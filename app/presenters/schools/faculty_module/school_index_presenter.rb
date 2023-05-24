module Schools
  module FacultyModule
    class SchoolIndexPresenter < ApplicationPresenter
      def initialize(view_context, school, status)
        super(view_context)

        @school = school
        @status = status
      end

      def faculty
        @faculty ||=
          if @status == "exited"
            current_school.faculty.exited
          else
            current_school.faculty.active
          end.includes(user: { avatar_attachment: :blob })
            .order(created_at: :desc)
            .page(params[:page])
            .per(10)
      end

      def props
        {
          coaches: faculty_details,
          schoolId: @school.id,
          authenticityToken: view.form_authenticity_token
        }
      end

      private

      def faculty_details
        faculty.map do |faculty|
          {
            id: faculty.id,
            name: faculty.name,
            email: faculty.user.email,
            title: faculty.title,
            imageUrl: faculty.user.image_or_avatar_url,
            public: faculty.public,
            connectLink: faculty.connect_link,
            exited: faculty.exited,
            imageFileName: faculty.image_filename,
            affiliation: faculty.user.affiliation
          }
        end
      end
    end
  end
end
