module FacultyModule
  # TODO: Spec FacultyModule::CreateService
  class CreateService
    def initialize(faculty_params)
      @faculty_params = faculty_params
    end

    def create
      User.transaction do
        school = @faculty_params[:school]
        user = User.where(email: @faculty_params[:email], school: school).first_or_create!

        return user.faculty if user.faculty.present?

        user.update!(name: @faculty_params[:name], title: @faculty_params[:title], linkedin_url: @faculty_params[:linkedin_url])
        user.avatar.attach(@faculty_params[:image]) if @faculty_params[:image].present?

        faculty = Faculty.create!(
          user: user,
          category: Faculty::CATEGORY_VISITING_COACHES,
          school: school,
          connect_link: @faculty_params[:connect_link],
          public: @faculty_params[:public],
          notify_for_submission: @faculty_params[:notify_for_submission]
        )
        faculty
      end
    end
  end
end
