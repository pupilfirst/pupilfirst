ActiveAdmin.register SchoolAdmin do
  menu parent: 'Schools'
  permit_params :user_id, :school_id
end
