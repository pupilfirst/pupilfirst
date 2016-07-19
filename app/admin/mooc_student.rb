ActiveAdmin.register MoocStudent do
  menu parent: 'StartInCollege'

  permit_params :name, :university_id, :college, :semester, :state, :gender, :user_id, :phone

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
end
