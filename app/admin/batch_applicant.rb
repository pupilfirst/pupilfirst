ActiveAdmin.register BatchApplicant do
  menu parent: 'Admissions', label: 'Applicants'

  permit_params :batch_application_id, :name, :gender, :email, :phone, :role, :team_lead, :tag_list

  scope :all, default: true
  scope :lead_signup
  scope :started_application
  scope :payment_initiated
  scope :conversion

  filter :name
  filter :email

  filter :ransack_tagged_with,
    as: :select,
    multiple: true,
    label: 'Tags',
    collection: -> { BatchApplicant.tag_counts_on(:tags).pluck(:name).sort }

  filter :batch_applications_batch_id_eq, as: :select, collection: proc { Batch.all }, label: 'With applications in batch'
  filter :phone
  filter :gender, as: :select, collection: Founder.valid_gender_values

  index do
    selectable_column

    column :name
    column :email
    column :phone
    column :reference

    column :last_created_application do |batch_applicant|
      application = batch_applicant.batch_applications.where(team_lead_id: batch_applicant.id).last

      if application.present?
        link_to application.display_name, admin_batch_application_path(application)
      end
    end

    column :tags do |batch_applicant|
      linked_tags(batch_applicant.tags, separator: ' | ')
    end

    actions
  end

  show do
    attributes_table do
      row :email
      row :name
      row :phone

      row :tags do |batch_applicant|
        linked_tags(batch_applicant.tags)
      end

      row :gender
      row :role

      row :applications do |batch_applicant|
        applications = batch_applicant.batch_applications

        if applications.present?
          ul do
            applications.each do |application|
              li do
                a href: admin_batch_application_path(application) do
                  application.display_name
                end

                span do
                  if application.team_lead_id == batch_applicant.id
                    ' (Team Lead)'
                  else
                    ' (Cofounder)'
                  end
                end
              end
            end
          end
        end
      end
    end

    panel 'Technical details' do
      attributes_table_for batch_applicant do
        row :id
        row :created_at
        row :updated_at
      end
    end
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
      f.input :email
      f.input :tag_list, input_html: { value: f.object.tag_list.join(','), 'data-tags' => BatchApplicant.tag_counts_on(:tags).pluck(:name).to_json }
      f.input :gender, as: :select, collection: Founder.valid_gender_values
      f.input :phone
      f.input :role, as: :select, collection: Founder.valid_roles
    end

    f.actions
  end
end
