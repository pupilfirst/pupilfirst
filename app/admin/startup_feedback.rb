ActiveAdmin.register StartupFeedback do

menu parent: 'Startups'
permit_params :feedback, :reference_url, :startup_id

index do
  selectable_column
  column :startup
  column :feedback
  column :reference_url
  actions
end

end
