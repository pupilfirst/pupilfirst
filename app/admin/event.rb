ActiveAdmin.register Event do
  controller do
    newrelic_ignore
  end

  form :partial => "form"
  permit_params :title, :description, :featured, :start_at_date, :start_at_time_hour, :start_at_time_minute, :end_at_date, :end_at_time_hour, :end_at_time_minute, :location_id, :category_id, :remote_picture_url, :picture, :user_id

  show do
    h3 event.title
    div do
      simple_format event.description
    end
    div event.featured
    div event.start_at
    div event.end_at
    div event.author
    div event.location.try :name
  end

    show do |event|
      attributes_table do
        row :title
        row :description do
          simple_format event.description
        end
        row :image do
          link_to(image_tag(event.picture_url(:thumb)), event.picture_url)
        end
        row :author
        row :featured
        row :dates do
          div "#{event.start_at.strftime('%a %b %e %Y,  %H:%M')} - #{event.end_at.strftime('%a %b %e %Y,  %H:%M')}  -- In UTC"
        end
        row :location
        row :category
      end
      active_admin_comments
    end

end
