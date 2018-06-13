module OneOff
  # Service to move the direct association between AdminUser and Faculty to a through association via user
  class AssociateFacultyToUserService
    def execute
      faculty_admins = AdminUser.where.not(faculty_id: nil)
      faculty_admins.each do |admin_user|
        faculty_id = admin_user.faculty_id
        Faculty.find(faculty_id).update!(user_id: admin_user.user_id)
      end
    end
  end
end
