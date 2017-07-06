ActiveAdmin.register BatchApplication do
  include DisableIntercom

  menu parent: 'Admissions', label: 'Applications', priority: 1

  permit_params :application_round_id, :application_stage_id, :team_achievement, :team_lead_id,
    :college, :team_size, :agreements_verified,
    batch_applicants_attributes: %i[id fee_payment_method], tag_list: []

  batch_action :promote, confirm: 'Are you sure?' do |ids|
    promoted = 0

    BatchApplication.where(id: ids).each do |batch_application|
      if batch_application.promotable?
        batch_application.promote!
        promoted += 1
      end
    end

    flash[:success] = "#{promoted} #{'application'.pluralize(promoted)} successfully promoted!"

    redirect_to collection_path
  end

  batch_action :mark_interview_attended, confirm: 'Are you sure?' do |ids|
    marked = 0

    BatchApplication.where(id: ids).each do |batch_application|
      if batch_application.interviewable?
        BatchApplications::MarkInterviewAttendedService.new(batch_application).execute
        marked += 1
      end
    end

    flash[:success] = "#{marked} applications have been marked as having attended interview."

    redirect_to collection_path
  end

  filter :application_round_batch_id_eq, label: 'Batch', as: :select, collection: proc { Batch.all }

  filter :application_round, as: :select, label: 'Application Round', collection: proc {
    batch_id = params.dig(:q, :application_round_batch_id_eq)

    if batch_id.present?
      ApplicationRound.where(batch_id: batch_id)
    else
      [['Pick batch first', '']]
    end
  }

  filter :application_stage, collection: -> { ApplicationStage.order(:number) }

  filter :ransack_tagged_with,
    as: :select,
    multiple: true,
    label: 'Tags',
    collection: -> { BatchApplication.tag_counts_on(:tags).pluck(:name).sort }

  filter :team_lead_name_eq, label: 'Team Lead Name'
  filter :team_lead_college_state_id_eq, label: 'State', as: :select, collection: proc { State.all }
  filter :team_lead_reference_contains, label: 'Reference contains'
  filter :swept_in_at_not_null, as: :boolean, label: 'Swept In'
  filter :agreements_verified

  filter :created_at

  scope :all, default: true
  scope :submitted_application
  scope :payment_initiated
  scope :payment_complete

  controller do
    def scoped_collection
      super.includes :payment, { application_round: :batch }, :application_stage, team_lead: { college: [:state] }
    end
  end

  index do
    selectable_column

    column :application_round

    column :team_lead do |batch_application|
      team_lead = batch_application.team_lead

      if team_lead.present?
        link_to team_lead.name, admin_batch_applicant_path(team_lead)
      else
        em 'Deleted'
      end
    end

    column 'Reference' do |batch_application|
      batch_application.team_lead&.reference
    end

    column 'Stage' do |batch_application|
      stage = batch_application.application_stage
      link_to "##{stage.number} #{stage.name}", admin_application_stage_path(stage)
    end

    column 'College' do |batch_application|
      team_lead = batch_application.team_lead

      if team_lead&.college.present?
        link_to team_lead.college.name, admin_college_path(team_lead.college)
      elsif team_lead&.college_text.present?
        span "#{team_lead.college_text} "
        span admin_create_college_link(team_lead.college_text)
      elsif batch_application.college_text.present?
        span batch_application.college_text
      else
        content_tag :em, 'Missing'
      end
    end

    column :state do |application|
      if application.team_lead&.college.present?
        link_to application.team_lead.college.state.name, admin_state_path(application.team_lead.college.state)
      else
        content_tag :em, 'Unknown'
      end
    end

    # column :score

    column 'Payment Date', sortable: 'payments.paid_at' do |application|
      payment = application.payment
      if payment.blank?
        'No Payment'
      elsif payment.paid?
        payment.paid_at.strftime('%b %d, %Y')
      else
        "#{payment.status.capitalize} on #{payment.created_at.strftime('%b %d, %Y')}"
      end
    end

    column :status

    actions defaults: false do |batch_application|
      span do
        link_to 'View', admin_batch_application_path(batch_application), class: 'view_link member_link'
      end

      span do
        link_to 'Edit', edit_admin_batch_application_path(batch_application), class: 'edit_link member_link'
      end

      span do
        if batch_application.payment.present?
          a class: 'disabled_action_link member_link', title: 'Disabled. Payment entry is present.' do
            s 'Delete'
          end
        else
          link_to(
            'Delete',
            admin_batch_application_path(batch_application),
            method: :delete,
            class: 'delete_link member_link',
            data: { confirm: 'Are you sure?' }
          )
        end
      end

      if batch_application.promotable?
        span do
          link_to 'Promote', promote_admin_batch_application_path(batch_application), method: :post, class: 'member_link', data: { confirm: 'Are you sure?' }
        end
      end

      if batch_application.interviewable?
        span do
          link_to 'Mark Interview Attended', mark_interview_attended_admin_batch_application_path(batch_application), method: :post, class: 'member_link', data: { confirm: 'Are you sure?' }
        end
      end
    end
  end

  csv do
    column :id

    column "Team Lead's Name" do |batch_application|
      team_lead = batch_application.team_lead
      team_lead.present? ? team_lead.name : 'Deleted'
    end

    column "Team Lead's Email" do |batch_application|
      team_lead = batch_application.team_lead
      team_lead.email if team_lead.present?
    end

    column 'Contact number' do |batch_application|
      team_lead = batch_application.team_lead
      team_lead.phone if team_lead.present?
    end

    column 'Reference' do |batch_application|
      batch_application.team_lead&.reference
    end

    column :payment_status do |batch_application|
      if batch_application.payment.present?
        t("payment.status.#{batch_application.payment.status}")
      else
        'No payment'
      end
    end

    column :stage do |batch_application|
      stage = batch_application.application_stage
      "##{stage.number} #{stage.name}"
    end

    column "Team Lead's Role" do |batch_application|
      team_lead = batch_application.team_lead
      team_lead.role if team_lead.present?
    end

    column :college do |batch_application|
      team_lead = batch_application.team_lead
      team_lead.college.name if team_lead&.college.present?
    end

    column :college_text do |batch_application|
      team_lead = batch_application.team_lead

      if team_lead&.college_text.present?
        team_lead.college_text
      elsif batch_application.college_text.present?
        batch_application.college_text
      end
    end

    column :state do |batch_application|
      batch_application.college&.state&.name
    end

    column :team_size

    column :cofounders do |batch_application|
      batch_application.cofounders.map do |cofounder|
        "#{cofounder.name} (#{cofounder.role})"
      end.join(', ')
    end

    column :cofounder_emails do |batch_application|
      batch_application.cofounders.map(&:email).join(', ')
    end

    column :created_at
  end

  show do
    attributes_table do
      row :application_round
      row :team_lead

      row :contact_number do
        batch_application&.team_lead&.phone
      end

      row :team_size

      row :payment_status do |batch_application|
        if batch_application.payment.present?
          link_to t("payment.status.#{batch_application.payment.status}"), admin_payment_path(batch_application.payment)
        else
          em 'No payment'
        end
      end

      row :cofounders do
        ul do
          batch_application.cofounders.each do |applicant|
            li do
              link_to applicant.name, admin_batch_applicant_path(applicant)
            end
          end
        end
      end

      row :fee_payment_details do
        ul do
          batch_application.batch_applicants.each do |applicant|
            li do
              "#{applicant.name} - #{applicant.fee_payment_method || 'Unknown'}"
            end
          end
        end
      end

      row :tags do |batch_application|
        linked_tags(batch_application.tags)
      end

      row :application_stage
      row :generate_certificate
      row :agreements_verified
      row :college
    end

    panel 'Technical details' do
      attributes_table_for batch_application do
        row :id
        row :created_at
        row :updated_at
        row :swept_at
        row :swept_in_at
      end
    end
  end

  member_action :promote, method: :post do
    batch_application = BatchApplication.find(params[:id])
    promoted_stage = batch_application.promote!

    IntercomLastApplicantEventUpdateJob.perform_later(batch_application.team_lead, 'selected_for_interview') if promoted_stage == ApplicationStage.find_by(name: 'Team Interview')

    flash[:success] = "Application has been promoted to #{promoted_stage.name}"
    redirect_back(fallback_location: admin_batch_applications_url)
  end

  member_action :mark_interview_attended, method: :post do
    batch_application = BatchApplication.find(params[:id])

    if batch_application.interviewable?
      BatchApplications::MarkInterviewAttendedService.new(batch_application).execute
      flash[:success] = 'Application has been marked as having attended interview.'
      redirect_back(fallback_location: admin_batch_applications_url)
    end
  end

  action_item :promote, only: :show do
    if batch_application.promotable?
      link_to('Promote to next stage', promote_admin_batch_application_path(batch_application), method: :post, data: { confirm: 'Are you sure?' })
    end
  end

  action_item :mark_interview_attended, only: :show do
    if batch_application.interviewable?
      link_to('Mark Interview Attended', mark_interview_attended_admin_batch_application_path(batch_application), method: :post, data: { confirm: 'Are you sure?' })
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs do
      f.input :application_round
      f.input :team_lead, collection: f.object.batch_applicants, include_blank: false
      f.input :team_size, as: :select, collection: 2..10, include_blank: false
      f.input :application_stage, collection: ApplicationStage.all.order(number: 'ASC')

      f.input :tag_list,
        as: :select,
        collection: BatchApplication.tag_counts_on(:tags).pluck(:name),
        multiple: true

      f.input :team_achievement

      f.has_many :batch_applicants, heading: 'Fee Payment Methods:', new_record: false do |g|
        g.input :fee_payment_method, as: :select, collection: BatchApplicant::FEE_PAYMENT_METHODS, label: g.object.name
      end
      f.input :agreements_verified
    end

    f.actions
  end
end
