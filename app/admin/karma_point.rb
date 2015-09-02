ActiveAdmin.register KarmaPoint do
  menu parent: 'Users'

  permit_params :user_id, :points, :activity_type, :created_at

  form do |f|
    f.inputs 'Basics'

    f.inputs 'Extra' do
      f.input :created_at, as: :date_select
    end

    f.actions
  end
end
