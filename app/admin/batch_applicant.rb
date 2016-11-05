ActiveAdmin.register BatchApplicant do
  include DisableIntercom

  menu parent: 'Admissions', label: 'Applicants'

  permit_params :name, :gender, :email, :phone, :role, :team_lead, :tag_list, :reference,
    :college_id, :notes, :fee_payment_method, { batch_application_ids: [] },
    college_attributes: [:name, :also_known_as, :city, :state_id, :established_year, :website, :contact_numbers, :replacement_university_id]

  scope :all, default: true
  scope :submitted_application
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
  filter :fee_payment_method, as: :select, collection: -> { BatchApplicant::FEE_PAYMENT_METHODS }
  filter :phone
  filter :reference_eq, as: :select, collection: proc { BatchApplicant.reference_sources[0..-2] }, label: 'Reference (Selected)'
  filter :reference, label: 'Reference (Free-form)'
  filter :gender, as: :select, collection: proc { Founder.valid_gender_values }
  filter :college_state_id_eq, label: 'State', as: :select, collection: proc { State.all }
  filter :college_id_null, label: 'College missing?', as: :boolean
  filter :created_at

  index do
    selectable_column

    column :name
    column :phone
    column :reference

    column :college do |batch_applicant|
      if batch_applicant.college.present?
        link_to batch_applicant.college.name, admin_college_path(batch_applicant.college)
      elsif batch_applicant.college_text.present?
        span "#{batch_applicant.college_text} "
        span admin_create_college_link(batch_applicant.college_text)
      else
        content_tag :em, 'Unknown'
      end
    end

    column :state do |batch_applicant|
      application = batch_applicant.batch_applications.last

      if batch_applicant.college.present?
        if batch_applicant.college.state.present?
          link_to batch_applicant.college.state.name, admin_state_path(batch_applicant.college.state)
        else
          content_tag :em, 'College without state'
        end
      elsif batch_applicant.college_text.present?
        content_tag :em, 'No linked college'
      elsif application&.state.present?
        span "#{application.state} "

        span do
          content_tag :em, '(Old data)'
        end
      elsif application&.university.present?
        span "#{application.university.location} "

        span do
          content_tag :em, '(Old data)'
        end
      else
        content_tag :em, 'Unknown - Please fix'
      end
    end

    column :notes

    column :last_created_application do |batch_applicant|
      application = batch_applicant.batch_applications.where(team_lead_id: batch_applicant.id).last

      if application.present?
        link_to application.display_name, admin_batch_application_path(application)
      end
    end

    column :latest_payment, sortable: 'latest_payment_at' do |batch_applicant|
      payment = batch_applicant.payments.order('created_at').last
      if payment.blank?
        'No Payment'
      elsif payment.paid?
        payment.paid_at.strftime('%b %d, %Y')
      else
        "#{payment.status.capitalize} on #{payment.created_at.strftime('%b %d, %Y')}"
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
      row :college
      row :college_text

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

      row :reference
      row :fee_payment_method
      row :notes
      row :last_sign_in_at
    end

    panel 'Technical details' do
      attributes_table_for batch_applicant do
        row :id
        row :sign_in_email_sent_at
        row :created_at
        row :updated_at
      end
    end
  end

  csv do
    column :id
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

    column :college do |batch_applicant|
      college = batch_applicant.college
      college.name if college.present?
    end

    column :college_text
    column :created_at
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :batch_applications, collection: BatchApplication.all.includes(:team_lead, :batch)
      f.input :name
      f.input :email
      f.input :tag_list, input_html: { value: f.object.tag_list.join(','), 'data-applicant-tags' => BatchApplicant.tag_counts_on(:tags).pluck(:name).to_json }
      f.input :gender, as: :select, collection: Founder.valid_gender_values
      f.input :phone
      f.input :college_text, label: 'College as text'
      f.input :college_id, input_html: { 'data-search-url' => colleges_url }
      f.input :role, as: :select, collection: Founder.valid_roles
      f.input :reference
      f.input :notes
      f.input :fee_payment_method, as: :select, collection: BatchApplicant::FEE_PAYMENT_METHODS
    end

    if f.object.college.blank? || !f.object.college&.persisted?
      div class: 'aa_batch_applicant_enable_create_college' do
        span { check_box_tag 'aa_batch_applicant_enable_create_college_checkbox' }
        span { label_tag 'aa_batch_applicant_enable_create_college_checkbox', 'Enable the form to create new college?' }
      end

      f.inputs 'Create missing college', for: [:college, College.new] do |cf|
        cf.input :name
        cf.input :also_known_as
        cf.input :city
        cf.input :state_id, as: :select, collection: State.all
        cf.input :established_year
        cf.input :website
        cf.input :contact_numbers
        cf.input :replacement_university_id, label: 'University', as: :select, collection: ReplacementUniversity.all
      end
    end

    f.actions
  end
end
