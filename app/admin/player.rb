ActiveAdmin.register Player do
  menu parent: 'Admissions', label: 'Tech-Hunt Players'

  actions :index, :show

  filter :user_email_contains
  filter :name
  filter :stage
  filter :college_name_contains
  filter :college_text

  controller do
    def scoped_collection
      super.includes :college, :user
    end
  end

  index do
    selectable_column

    column :name

    column :college do |player|
      if player.college.present?
        link_to player.college.name, admin_college_path(player.college)
      elsif player.college_text.present?
        span "#{player.college_text} "
        span admin_create_college_link(player.college_text)
      else
        content_tag :em, 'Unknown'
      end
    end

    column :stage

    actions
  end
end
