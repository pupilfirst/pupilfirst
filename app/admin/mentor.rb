ActiveAdmin.register Mentor do
  controller do
    newrelic_ignore
  end

  form do |f|
    f.inputs 'Mentor' do
      f.input :user
      f.input :company
      f.input :availability
      f.input :company_level, collection: Startup.valid_product_progress_values
      f.input :cost_to_company
      f.input :time_donate_percentage
      f.input :verified_at, as: :date
    end

    f.actions
  end

  permit_params :user_id, :company_id, :availability, :company_level, :cost_to_company, :time_donate_percentage, :verified_at
end
