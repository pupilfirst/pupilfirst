ActiveAdmin.register Event do
  controller do
    newrelic_ignore
    after_filter :update_admin_user_as_author, only: [:update, :create]

    def update_admin_user_as_author
      @event.update!(author: current_admin_user)
    end

  end

  form :partial => "form"
  permit_params :title, :description, :featured, :approved, :start_at_date, :start_at_time_hour, :start_at_time_minute, :end_at_date, :end_at_time_hour, :end_at_time_minute, :location, :category_id, :remote_picture_url, :picture, :user_id, :_wysihtml5_mode, :time_zone, :posters_name, :posters_email, :posters_phone_number

  preserve_default_filters!
  filter :id

  show do
    h3 event.title
    div do
      simple_format event.description
    end
    div event.featured
    div event.approved
    div event.start_at
    div event.end_at
    div event.author
    div event.location
  end
  index do
    column :id
    column :title
    column :description do |event|
      event.description[0..100] rescue nil
    end
    column :featured
    column :approved
    column :start_at do |event|
      event.start_at.in_time_zone('Mumbai').strftime('%a %b %e %Y, %H:%M') rescue nil
    end
    column :end_at do |event|
      event.end_at.in_time_zone('Mumbai').strftime('%a %b %e %Y, %H:%M') rescue nil
    end
    column :author
    column :location
    actions
  end

    show do |event|
      attributes_table do
        row :id
        row :title
        row :description do
          simple_format event.description
        end
        row :image do
          link_to(image_tag(event.picture_url(:thumb)), event.picture_url)
        end
        row :author
        row :featured
        row :approved
        row :dates do
          div "#{event.start_at.in_time_zone('Mumbai').strftime('%a %b %e %Y,  %H:%M')} - #{event.end_at.in_time_zone('Mumbai').strftime('%a %b %e %Y,  %H:%M')}  -- In GMT+05:30"
        end
        row :location
        row :category
      end
    end

end
