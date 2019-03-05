module FacultyModule
  # TODO: Spec FacultyModule::CreateService
  class CreateService
    def initialize(email, name, school)
      @email = email
      @name = name
      @school = school
    end

    def create
      User.transaction do
        user = User.where(email: @email).first_or_create!

        return user.faculty.where(school: @school).first if user.faculty.where(school: @school).any?

        Faculty.create!(
          user: user,
          name: @name,
          category: Faculty::CATEGORY_VISITING_COACHES,
          title: 'Coach',
          image: Rails.root.join('spec', 'support', 'uploads', 'faculty', 'mickey_mouse.jpg').open,
          inactive: true,
          school: @school
        )
      end
    end
  end
end
