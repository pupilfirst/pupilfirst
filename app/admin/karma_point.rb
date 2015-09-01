ActiveAdmin.register KarmaPoint do
  menu parent: 'Users'

  permit_params :user_id, :points, :activity_type
end
