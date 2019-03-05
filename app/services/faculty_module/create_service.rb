module FacultyModule
  # TODO: Spec FacultyModule::CreateService
  class CreateService
    def initialize(email, name)
      @email = email
      @name = name
    end

    def create
      User.transaction do
        user = User.where(email: @email).first_or_create!

        return user.faculty if user.faculty.present?

        Faculty.create!(
          user: user,
          name: @name,
          category: Faculty::CATEGORY_VISITING_COACHES,
          title: 'Coach',
          image: Rails.root.join('spec', 'support', 'uploads', 'faculty', 'mickey_mouse.jpg').open
        )
      end
    end
  end
end
