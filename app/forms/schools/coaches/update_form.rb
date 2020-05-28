module Schools
  module Coaches
    class UpdateForm < Reform::Form
      property :name, validates: { presence: true, length: { maximum: 250 } }, virtual: true
      property :title, validates: { presence: true, length: { maximum: 250 } }
      property :connect_link
      property :exited
      property :public
      property :image, virtual: true, validates: { image: true, file_size: { less_than: 5.megabytes }, allow_blank: true }
      property :school_id, virtual: true, validates: { presence: true }
      property :affiliation, virtual: true

      def save
        Faculty.transaction do
          user = model.user
          user.update!(user_params)
          user.avatar.attach(image) if image.present?

          model.update!(faculty_params)
        end

        clear_faculty_enrollments if model.exited?

        model
      end

      private

      def school
        School.find_by(id: school_id)
      end

      def user_params
        {
          name: name,
          title: title,
          affiliation: affiliation
        }
      end

      def faculty_params
        {
          connect_link: connect_link,
          public: public,
          exited: exited
        }
      end

      def faculty
        @faculty ||= school.faculty.find_by(id: id)
      end

      def clear_faculty_enrollments
        FacultyCourseEnrollment.where(faculty: faculty).destroy_all
        FacultyStartupEnrollment.where(faculty: faculty).destroy_all
      end
    end
  end
end
