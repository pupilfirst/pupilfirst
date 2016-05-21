ActiveAdmin.register BatchApplicant do
  menu parent: 'Batches'

  permit_params :batch_application_id, :name, :gender, :email, :phone, :role, :team_lead

  filter :batch_application_batch_id_eq, as: :select, collection: Batch.all, label: 'Batch'
  filter :batch_application
  filter :name
  filter :email
  filter :phone
  filter :gender, as: :select, collection: Founder.valid_gender_values
  filter :team_lead

  index do
    selectable_column

    column :name
    column :email
    column :phone
    column :role
    column :gender
    column :team_lead

    actions
  end
end
