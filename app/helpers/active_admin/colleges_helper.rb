module ActiveAdmin
  module CollegesHelper
    def admin_create_college_link(college_name)
      "(#{link_to 'Create', new_admin_college_path(college: { name: college_name })})".html_safe
    end
  end
end
