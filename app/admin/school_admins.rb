ActiveAdmin.register SchoolAdmin do
  menu parent: 'Schools'
  permit_params :user_id, :school_id
  actions :index, :show

  filter :school
end
