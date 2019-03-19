module FacultyModule
  # TODO: Spec FacultyModule::CreateService
  class CreateService
    def initialize(faculty_params)
      @faculty_params = faculty_params
    end

    def create
      User.transaction do
        user = User.where(email: @faculty_params[:email]).first_or_create!

        return user.faculty.where(school: @faculty_params[:school]).first if user.faculty.where(school: @faculty_params[:school]).any?

        faculty = Faculty.create!(
          user: user,
          name: @faculty_params[:name],
          category: Faculty::CATEGORY_VISITING_COACHES,
          title: @faculty_params[:title],
          school: @faculty_params[:school],
          linkedin_url: @faculty_params[:linkedin_url],
          connect_link: @faculty_params[:connect_link],
          public: @faculty_params[:public],
          notify_for_submission: @faculty_params[:notify_for_submission]
        )
        faculty.image.attach(@faculty_params[:image])
        faculty
      end
    end
  end
end
