ActiveAdmin.register Mentor do
  menu parent: 'Mentoring'

  controller do
    newrelic_ignore
  end

  form do |f|
    f.inputs 'Mentor' do
      f.input :user
      f.input :company
      f.input :days_available, collection: Mentor.valid_days_available
      f.input :time_available, collection: Mentor.valid_time_available 
      f.input :company_level, collection: Startup.valid_product_progress_values
      f.input :verified_at, as: :date_select
    end

    f.actions
  end

  permit_params :user_id, :company_id, :days_available, :time_available, :company_level, :verified_at
end
