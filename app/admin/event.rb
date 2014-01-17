ActiveAdmin.register Event do
  controller do
    newrelic_ignore

    before_filter :convert_time_zone, only: [:update, :create]

    def convert_time_zone
      return false unless params[:event][:time_zone].present?
      zone = ActiveSupport::TimeZone[params[:event][:time_zone]]
      e = params[:event]
      [:start_at, :end_at].each do |date_type|
        time = Time.parse(e["#{date_type}_date".to_s]+" "+ e["#{date_type}_time_hour".to_s]+":"+ e["#{date_type}_time_minute".to_s] +" UTC") - zone.utc_offset
        params[:event]["#{date_type}_date".to_s] = time.strftime("%F")
        params[:event]["#{date_type}_time_hour".to_s] = time.hour
        params[:event]["#{date_type}_time_minute".to_s] = time.min
      end
      params[:event].delete(:time_zone)
    end
  end

  form :partial => "form"
  permit_params :title, :description, :featured, :start_at_date, :start_at_time_hour, :start_at_time_minute, :end_at_date, :end_at_time_hour, :end_at_time_minute, :location_id, :category_id, :remote_picture_url, :picture, :user_id, :_wysihtml5_mode, :time_zone

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
  index do
    column :title
    column :description do |event|
      event.description[0..100] rescue nil
    end
    column :featured
    column :start_at do |event|
      event.start_at.in_time_zone('Mumbai').strftime('%a %b %e %Y, %H:%M') rescue nil
    end
    column :end_at do |event|
      event.end_at.in_time_zone('Mumbai').strftime('%a %b %e %Y, %H:%M') rescue nil
    end
    column :author
    column :location
    default_actions
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
          div "#{event.start_at.in_time_zone('Mumbai').strftime('%a %b %e %Y,  %H:%M')} - #{event.end_at.in_time_zone('Mumbai').strftime('%a %b %e %Y,  %H:%M')}  -- In GMT+05:30"
        end
        row :location
        row :category
      end
      active_admin_comments
    end

end
