ActiveAdmin.register Batch do
  include DisableIntercom

  menu parent: 'Admissions'

  permit_params :theme, :description, :start_date, :end_date, :batch_number, :slack_channel, :application_stage_id,
    :application_stage_deadline_date, :application_stage_deadline_time_hour, :application_stage_deadline_time_minute,
    :next_stage_starts_on

  config.sort_order = 'batch_number_asc'

  index do
    selectable_column

    column :batch_number
    column :theme
    column :start_date
    column :end_date
    column :application_stage

    actions do |batch|
      if batch.application_stage&.final_stage?
        span do
          link_to 'Invite all founders', selected_applications_admin_batch_path(batch)
        end
      end
    end
  end

  show do
    attributes_table do
      row :batch_number
      row :theme
      row :description
      row :start_date
      row :end_date
      row :application_stage
      row :application_stage_deadline
      row :next_stage_starts_on
      row :invites_sent_at
      row :slack_channel
    end

    panel 'Technical details' do
      attributes_table_for batch do
        row :id
        row :created_at
        row :updated_at
      end
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs 'Batch Details' do
      f.input :application_stage, collection: ApplicationStage.all.order(number: 'ASC')
      f.input :application_stage_deadline, as: :just_datetime_picker
      f.input :next_stage_starts_on, as: :datepicker, label: 'Tentative start date for next stage'
      f.input :batch_number
      f.input :theme
      f.input :description
      f.input :start_date, as: :datepicker
      f.input :end_date, as: :datepicker
      f.input :slack_channel
    end

    f.actions
  end

  member_action :sweep_in_applications do
    @batch = Batch.find params[:id]
    @unbatched = BatchApplication.where(batch: nil)
    render 'sweep_in_applications'
  end

  action_item :sweep_in_applications, only: :show, if: proc { resource&.application_stage&.initial_stage? } do
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

  member_action :sweep_in_unbatched, method: :post do
    batch = Batch.find params[:id]

    if batch.application_stage.initial_stage?
      BatchApplication.where(batch: nil).update_all(batch_id: batch.id)
      flash[:success] = "All unbatched applications have been assigned to batch ##{batch.batch_number}"
    else
      flash[:error] = "Did not initiate sweep. Batch ##{batch.batch_number} is not in initial stage."
    end

    redirect_to admin_batch_path(batch)
  end

  member_action :sweep_in_unpaid, method: :post do
    batch = Batch.find params[:id]
    source_batch = Batch.find params[:sweep_in_unpaid_applications][:source_batch_id]

    if batch.application_stage.initial_stage?
      uninitiated_applications = source_batch.batch_applications.includes(:payment).where(payments: { id: nil })
      unpaid_applications = source_batch.batch_applications.joins(:payment).merge(Payment.requested)
      applications_count = uninitiated_applications.count + unpaid_applications.count
      (uninitiated_applications + unpaid_applications).each { |application| application.update!(batch_id: batch.id) }

      flash[:success] = "#{applications_count} unpaid applications from Batch ##{source_batch.batch_number} have been assigned to batch ##{batch.batch_number}"
    else
      flash[:error] = "Did not initiate sweep. Batch ##{batch.batch_number} is not in initial stage."
    end

    redirect_to admin_batch_path(batch)
  end

  member_action :sweep_in_rejects, method: :post do
    batch = Batch.find params[:id]
    source_batch = Batch.find params[:sweep_in_rejects][:source_batch_id]

    if batch.application_stage.initial_stage?
      current_stage_number = source_batch.application_stage.number

      rejected_and_left_behind_applications = source_batch.batch_applications.joins(:application_stage).
        where('application_stages.number < ?', current_stage_number).
        where('application_stages.number != 1')

      expired_applications = source_batch.batch_applications.joins(:application_stage).
        where(application_stages: { number: current_stage_number } ).
        where('application_stages.number != 1').where()

      raise NotImplementedError

      flash[:success] = "#{applications_count} rejected or expired applications from Batch ##{source_batch.batch_number} have been copied to batch ##{batch.batch_number}"
    else
      flash[:error] = "Did not initiate sweep. Batch ##{batch.batch_number} is not in initial stage."
    end

    redirect_to admin_batch_path(batch)
  end
end
