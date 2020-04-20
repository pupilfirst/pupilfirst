class SchoolAdminMailer < SchoolMailer
  # @param school_admin [SchoolAdmin] Existing school admin
  # @param new_school_admin [SchoolAdmin] Newly created school admin
  def school_admin_added(school_admin, new_school_admin)
    @school_admin = school_admin
    @new_school_admin = new_school_admin
    @school = school_admin.user.school
    simple_roadie_mail(school_admin.email, "New School Admin Added")
  end
end
