ActiveAdmin.register TimelineEvent do
  menu parent: 'Startups'
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  permit_params :title, :description, :iteration, :event_type, :image, :links, :event_on
  #
  # or
  #
  # permit_params do
  #   permitted = [:permitted, :attributes]
  #   permitted << :other if resource.something?
  #   permitted
  # end

  form do |f|
    f.inputs 'Event Details' do
      f.input :title
      f.input :event_type, collection: TimelineEvent.valid_types, include_blank: false
      f.input :description
      f.input :iteration
      f.input :image
      f.input :links
      f.input :event_on, as: :datepicker
    end
    f.actions
  end

end
