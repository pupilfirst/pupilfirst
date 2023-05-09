module FacultyModule
  class CreateService
    def initialize(faculty_params)
      @faculty_params = faculty_params
    end

    def create
      school = @faculty_params[:school]

      user =
        User.where(
          email: @faculty_params[:email],
          school: school
        ).first_or_create!(title: "Coach")

      return user.faculty if user.faculty.present?

      User.transaction do
        user.update!(
          name: @faculty_params[:name],
          title: @faculty_params[:title],
          affiliation: @faculty_params[:affiliation]
        )

        if @faculty_params[:image].present?
          user.avatar.attach(@faculty_params[:image])
        end

        Faculty.create!(
          user: user,
          category: Faculty::CATEGORY_VISITING_COACHES,
          connect_link: @faculty_params[:connect_link],
          public: @faculty_params[:public]
        )
      end
    end
  end
end
