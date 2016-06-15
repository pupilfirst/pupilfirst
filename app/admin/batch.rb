ActiveAdmin.register Batch do
  permit_params :theme, :description, :start_date, :end_date, :batch_number, :slack_channel, :application_stage_id,
    :application_stage_deadline_date, :application_stage_deadline_time_hour, :application_stage_deadline_time_minute

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
          link_to 'Invite all founders', invite_all_founders_admin_batch_path(batch)
        end
      end
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs 'Batch Details' do
      f.input :application_stage, collection: ApplicationStage.all.order(number: 'ASC')
      f.input :application_stage_deadline, as: :just_datetime_picker
      f.input :batch_number
      f.input :theme
      f.input :description
      f.input :start_date, as: :datepicker
      f.input :end_date, as: :datepicker
      f.input :slack_channel
    end

    f.actions
  end

  member_action :invite_all_founders do
    @batch = Batch.find params[:id]
    render 'batch_invite_page'
  end
end
