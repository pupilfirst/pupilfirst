ActiveAdmin.register MoocStudent do
  include DisableIntercom

  menu parent: 'SixWays'

  permit_params :name, :college_id, :semester, :state, :gender, :user_id, :phone

  filter :name
  filter :email
  filter :phone
  filter :college_name_contains
  filter :semester
  filter :state
  filter :gender, as: :select, collection: Founder.valid_gender_values
  filter :created_at

  scope :all, default: true
  scope 'Module 2 Complete' do |mooc_students|
    mooc_students.completed_quiz(CourseModule.find_by(module_number: 2))
  end
  scope 'Module 3 Complete' do |mooc_students|
    mooc_students.completed_quiz(CourseModule.find_by(module_number: 3))
  end

  index do
    selectable_column

    column :name_or_email do |student|
      student.name.present? ? student.name : student.email
    end
    column :college
    column :state

    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :name
      f.input :college_id, as: :select, input_html: { 'data-search-url' => colleges_url }, collection: f.object.college.present? ? [f.object.college] : []
      f.input :college_text, label: 'College as text'
      f.input :state, as: :select, collection: University.valid_state_names
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
    column :state
  end
end
