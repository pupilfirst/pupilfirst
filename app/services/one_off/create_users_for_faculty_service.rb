module OneOff
  # Service to create User records for all faculty with email.
  # Note: Run after OneOff::AssociateFacultyToUserService for added safety
  class CreateUsersForFacultyService
    def execute
      faculty = Faculty.where(user: nil)
      faculty.each do |f|
        next if f.email.blank?
        user = User.with_email(f.email) || User.create!(email: f.email)
        f.update!(user: user)
      end
    end
  end
end
