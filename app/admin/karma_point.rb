ActiveAdmin.register KarmaPoint do
  menu parent: 'Users'

  permit_params :user_id, :points, :activity_type, :created_at

  form do |f|
    f.inputs 'Extra' do
      f.input :user, collection: User.founders,
        member_label: Proc.new { |u| "#{u.fullname} - #{u.title.present? ? (u.title + ', ') : ''}#{u.startup.name}" },
        input_html: { style: 'width: calc(80% - 22px);' }
      f.input :points
      f.input :activity_type
      f.input :created_at, as: :datepicker
    end

    f.actions
  end
end
