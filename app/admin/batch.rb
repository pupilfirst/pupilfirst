ActiveAdmin.register Batch do
  permit_params :name, :description, :start_date, :end_date, :batch_number, :slack_channel, :application_stage_id,
    :application_stage_deadline_date, :application_stage_deadline_time_hour, :application_stage_deadline_time_minute

  config.sort_order = 'batch_number_asc'

  index do
    selectable_column

    column :batch_number
    column :name
    column :start_date
    column :end_date
    column :application_stage
    actions
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs 'Batch Details' do
      f.input :application_stage, collection: ApplicationStage.all.order(number: 'ASC')
      f.input :application_stage_deadline, as: :just_datetime_picker
      f.input :batch_number
      f.input :name
      f.input :description
      f.input :start_date, as: :datepicker
      f.input :end_date, as: :datepicker
      f.input :slack_channel
    end

    f.actions
  end
end
