ActiveAdmin.register Batch do
  include DisableIntercom

  menu parent: 'Admissions'

  permit_params :theme, :description, :start_date, :end_date, :batch_number, :slack_channel, :campaign_start_at, :target_application_count, batch_stages_attributes: [
    :id, :application_stage_id, :starts_at_date, :starts_at_time_hour, :starts_at_time_minute, :ends_at_date,
    :ends_at_time_hour, :ends_at_time_minute, :_destroy
  ]

  config.sort_order = 'batch_number_asc'

  filter :batch_number
  filter :theme
  filter :start_date
  filter :end_date

  index do
    selectable_column

    column :batch_number
    column :theme
    column :start_date
    column :end_date

    column :active_stages do |batch|
      batch.batch_stages.select(&:active?).map { |active_batch_stage| active_batch_stage.application_stage.name }.join ', '
    end

    actions do |batch|
      if batch.applications_complete?
        span do
          link_to 'Invite all founders', selected_applications_admin_batch_path(batch)
        end
      end
    end
  end

  show do |batch|
    attributes_table do
      row :batch_number
      row :theme
      row :description
      row :start_date
      row :end_date
      row :invites_sent_at
      row :slack_channel
      row :campaign_start_at
      row :target_application_count
    end

    panel 'Application Stages' do
      batch.batch_stages.sort_by { |batch_stage| batch_stage.application_stage.number }.each do |batch_stage|
        attributes_table_for batch_stage do
          row :application_stage
          row :starts_at
          row :ends_at
        end
      end
    end

    panel 'Technical details' do
      attributes_table_for batch do
        row :id
        row :created_at
        row :updated_at
      end
    end

    panel 'Batch Emails' do
      ul do
        li do
          span do
            link_to 'Send batch progress email', send_email_admin_batch_path(batch, type: 'batch_progress'), method: :post, data: { confirm: 'Are you sure?' }
          end

          span " - These should be sent after a batch has progressed from one stage to another. It notifies applicants who have progressed, and sends a rejection mail to those who haven't (rejection mail is not sent for applications in stage 1)."
        end
      end
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs 'Batch Details' do
      f.input :batch_number
      f.input :theme
      f.input :description
      f.input :start_date, as: :datepicker
      f.input :end_date, as: :datepicker
      f.input :slack_channel
      f.input :campaign_start_at, label: 'Campaign Start Date', as: :datepicker
      f.input :target_application_count
    end

    f.inputs 'Stage Dates' do
      f.has_many :batch_stages, heading: false, allow_destroy: true, new_record: 'Add Stage' do |s|
        s.input :application_stage, collection: ApplicationStage.order('number ASC')
        s.input :starts_at, as: :just_datetime_picker
        s.input :ends_at, as: :just_datetime_picker
      end
    end

    f.actions
  end

  member_action :send_email, method: :post do
    batch = Batch.find params[:id]

    case params[:type]
      when 'batch_progress'
        if batch.initial_stage? || batch.final_stage?
          flash[:error] = 'Mails not sent. Batch is in first stage, or is closed.'
        else
          EmailApplicantsJob.perform_later(batch)
          flash[:success] = 'Mails have been queued'
        end
      else
        flash[:error] = "Mails not sent. Unknown type '#{params[:type]}' requested."
    end

    redirect_to admin_batch_path(batch)
  end

  member_action :sweep_in_applications do
    @batch = Batch.find params[:id]
    @unbatched = BatchApplication.where(batch: nil)
    render 'sweep_in_applications'
  end

  action_item :sweep_in_applications, only: :show, if: proc { resource&.initial_stage? } do
    link_to('Sweep in Applications', sweep_in_applications_admin_batch_path(Batch.find(params[:id])))
  end

  member_action :selected_applications do
    @batch = Batch.find params[:id]
    render 'batch_invite_page'
  end

  action_item :invite_all, only: :show, if: proc { !resource.invites_sent? } do
    link_to('Invite All Founders', selected_applications_admin_batch_path(Batch.find(params[:id])))
  end

  member_action :invite_all_selected do
    batch = Batch.find params[:id]

    batch.invite_selected_candidates!

    if batch.invites_sent?
      flash[:success] = 'Invites sent to all selected candidates!'
    else
      flash[:error] = 'Something went wrong. Please try inviting again!'
    end

    redirect_to selected_applications_admin_batch_path(batch)
  end

  member_action :create_sweep_job, method: :post do
    sweep_unpaid = params[:sweep_in_applications][:sweep_unpaid] == '1'
    sweep_batch_ids = (params[:sweep_in_applications][:source_batch_ids] - ['']).map(&:to_i)
    skip_payment = params.dig(:sweep_in_applications, :skip_payment) == '1'

    batch = Batch.find params[:id]

    if batch.initial_stage?
      batch_sweep_job = BatchSweepJob.new(batch.id, sweep_unpaid, sweep_batch_ids, current_admin_user.email, skip_payment: skip_payment)

      if Rails.env.production?
        batch_sweep_job.perform_later
      else
        batch_sweep_job.perform_now
      end

      flash[:success] = 'Sweep Job has been created. You will be sent an email with the results when it is complete.'
    else
      flash[:error] = "Did not initiate sweep. Batch ##{batch.batch_number} is not in initial stage."
    end

    redirect_to admin_batch_path(batch)
  end
end
