ActiveAdmin.register MoocStudent do
  include DisableIntercom

  menu parent: 'SixWays'

  permit_params :name, :university_id, :college, :semester, :state, :gender, :user_id, :phone

  filter :name
  filter :email
  filter :phone
  filter :university_name_contains
  filter :college
  filter :semester
  filter :state
  filter :gender, as: :select, collection: Founder.valid_gender_values
  filter :created_at

  controller do
    def scoped_collection
      super.includes :university
    end
  end

  index do
    selectable_column

    column :name_or_email do |student|
      student.name.present? ? student.name : student.email
    end
    column :university
    column :college
    column :state

    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :name
      f.input :university_id, as: :select, collection: University.all
      f.input :college
      f.input :state
      f.input :gender, as: :select, collection: Founder.valid_gender_values, include_blank: false
      f.input :user_id, as: :select, collection: User.all.pluck(:email, :id), label_method: :first
      f.input :phone
    end

    f.actions
  end

  csv do
    column :name
    column(:email) { |student| student.user.email }
    column :phone
    column :gender
    column :college
    column :semester
    column(:university) { |student| student.university.name }
    column :state
  end
end
