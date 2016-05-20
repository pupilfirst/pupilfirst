ActiveAdmin.register BatchApplicant do
  menu parent: 'Batches'

  permit_params :batch_application_id, :name, :gender, :email, :phone, :role, :team_lead
end
