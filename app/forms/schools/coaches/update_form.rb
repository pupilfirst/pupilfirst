module Schools
  module Coaches
    class UpdateForm < Reform::Form
      property :email, validates: { email: true }, virtual: true
      property :name, validates: { presence: true, length: { maximum: 250 } }, virtual: true
      property :title, validates: { presence: true, length: { maximum: 250 } }
      property :linkedin_url, virtual: true
      property :connect_link
      property :notify_for_submission
      property :exited
      property :public
      property :image, virtual: true, validates: { file_content_type: { allow: ['image/jpeg', 'image/png'] }, file_size: { less_than: 2.gigabytes } }
      property :school_id, virtual: true, validates: { presence: true }

      def save
        Faculty.transaction do
          user = User.where(email: email).first_or_create!
          model.update!(faculty_params.merge(user: user))

          user_profile = UserProfile.where(user: user, school: school).first_or_create!
          user_profile.update!(user_profile_params)
          user_profile.avatar.attach(image) if image.present?
        end

        clear_faculty_enrollments if model.exited?

        model
      end

      private

      def school
        School.find_by(id: school_id)
      end

      def user_profile_params
        {
          name: name,
          title: title,
          linkedin_url: linkedin_url
        }
      end

      def faculty_params
        {
          school: school,
          connect_link: connect_link,
          public: public,
          notify_for_submission: notify_for_submission,
          exited: exited
        }
      end

      def faculty
        @faculty ||= Faculty.find_by(id: id)
      end

      def clear_faculty_enrollments
        FacultyCourseEnrollment.where(faculty: faculty).destroy_all
        FacultyStartupEnrollment.where(faculty: faculty).destroy_all
      end
    end
  end
end
