module FacultyModule
  # TODO: Spec FacultyModule::CreateService
  class CreateService
    def initialize(email, name, title)
      @email = email
      @name = name
      @title = title
    end

    def create
      User.transaction do
        user = User.where(email: @email).first_or_create!

        return user.faculty if user.faculty.present?

        Faculty.create!(
          user: user,
          name: @name,
          category: Faculty::CATEGORY_VISITING_COACHES,
          title: @title,
          image: Rails.root.join('spec', 'support', 'uploads', 'faculty', 'mickey_mouse.jpg').open,
          inactive: true
        )
      end
    end
  end
end
