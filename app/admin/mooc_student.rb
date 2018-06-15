ActiveAdmin.register MoocStudent do
  menu parent: 'SixWays'

  permit_params :name, :college_id, :semester, :state, :gender, :user_id, :phone

  filter :name
  filter :email
  filter :phone
  filter :college_name_contains
  filter :semester
  filter :gender, as: :select, collection: -> { Founder.valid_gender_values }
  filter :created_at

  scope :all, default: true
  scope 'Module 2 Complete' do |mooc_students|
    mooc_students.completed_quiz(CourseModule.find_by(module_number: 2))
  end
  scope 'Module 3 Complete' do |mooc_students|
    mooc_students.completed_quiz(CourseModule.find_by(module_number: 3))
  end

  controller do
    include DisableIntercom

    def scoped_collection
      super.includes :college
    end
  end

  index do
    selectable_column

    column :name_or_email do |student|
      student.name.presence || student.email
    end

    column :college do |mooc_student|
      if mooc_student.college.present?
        link_to mooc_student.college.name, admin_college_path(mooc_student.college)
      elsif mooc_student.college_text.present?
        span "#{mooc_student.college_text} "
        span admin_create_college_link(mooc_student.college_text)
      else
        content_tag :em, 'Unknown'
      end
    end

    column :state do |mooc_student|
      if mooc_student.college.present?
        mooc_student.college.state.name
      else
        em 'Unknown'
      end
    end

    actions
  end

  action_item :impersonate, only: :show, if: proc { can? :impersonate, User } do
    link_to 'Impersonate', impersonate_admin_user_path(mooc_student.user), method: :post
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :name
      f.input :college_id, as: :select, input_html: { 'data-search-url' => colleges_url }, collection: f.object.college.present? ? [f.object.college] : []
      f.input :college_text, label: 'College as text'
      f.input :gender, as: :select, collection: Founder.valid_gender_values, include_blank: false
      f.input :phone
    end

    f.actions
  end

  csv do
    column :name
    column(:email) { |student| student.user.email }
    column :phone
    column :gender
    column(:college) { |student| student.college.present? ? student.college.name : student.college_text }
    column :semester
  end
end
