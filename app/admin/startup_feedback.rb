ActiveAdmin.register StartupFeedback do

menu parent: 'Startups'
permit_params :feedback, :reference_url, :startup_id, :send_email

index do
  selectable_column
  column :startup
  column :feedback
  column :reference_url
  actions
end

form do |f|
    f.inputs 'Event Details' do
      f.input :startup
      f.input :feedback
      f.input :reference_url
      f.input :send_email, :as => :boolean, :label => "Send as email to founders"
    end
    f.actions
end

end
