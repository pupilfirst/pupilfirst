ActiveAdmin.register Batch do
  include DisableIntercom

  menu parent: 'Admissions'

  permit_params :theme, :description, :start_date, :end_date, :batch_number, :slack_channel

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

    actions
  end

  show do |batch|
    attributes_table do
      row :batch_number
      row :theme
      row :description
      row :start_date
      row :end_date
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
      f.input :batch_number
      f.input :theme
      f.input :description
      f.input :start_date, as: :datepicker
      f.input :end_date, as: :datepicker
      f.input :slack_channel
    end

    f.actions
  end
end
