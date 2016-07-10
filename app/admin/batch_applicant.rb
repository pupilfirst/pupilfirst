ActiveAdmin.register BatchApplicant do
  menu parent: 'Batches'

  permit_params :batch_application_id, :name, :gender, :email, :phone, :role, :team_lead

  filter :batch_applications_batch_id_eq, as: :select, collection: proc { Batch.all }, label: 'Batch'
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

  csv do
    column :name
    column :email
    column :phone
    column :gender

    column :applications do |batch_applicant|
      if batch_applicant.batch_applications.present?
        batch_applicant.batch_applications.map do |application|
          if application.team_lead == batch_applicant
            "Team lead on batch #{application.batch.batch_number}"
          else
            "Cofounder on batch #{application.batch.batch_number}"
          end
        end.join(', ')
      end
    end

    column :created_at
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :batch_applications
      f.input :name
      f.input :gender, as: :select, collection: Founder.valid_gender_values
      f.input :email
      f.input :phone
      f.input :role, as: :select, collection: Founder.valid_roles
    end

    f.actions
  end
end
