ActiveAdmin.register TimelineEvent do
  menu parent: 'Startups'
  permit_params :title, :description, :iteration, :timeline_event_type_id, :image, :links, :event_on, :startup_id, :verified_at

  preserve_default_filters!
  filter :startup_batch, as: :select, collection: (1..10)

  scope :all
  scope :batched

  index do
    selectable_column

    column :timeline_event_type
    column :startup
    column :event_on
    column :verified_at

    actions
  end

  member_action :delete_link, method: :put do
    timeline_event = TimelineEvent.find params[:id]
    timeline_event.links.delete_at(params[:link_index].to_i)
    timeline_event.save!

    redirect_to action: :show
  end

  member_action :add_link, method: :put do
    timeline_event = TimelineEvent.find params[:id]
    timeline_event.links << { title: params[:link_title], url: params[:link_url] }
    timeline_event.save!

    redirect_to action: :show
  end

  member_action :verify, method: :post do
    TimelineEvent.find(params[:id]).verify!
    redirect_to action: :show
  end

  member_action :unverify, method: :post do
    TimelineEvent.find(params[:id]).unverify!
    redirect_to action: :show
  end

  form do |f|
    f.inputs 'Event Details' do
      f.input :startup
      f.input :title
      f.input :timeline_event_type
      f.input :description
      f.input :iteration
      f.input :image
      f.input :event_on, as: :datepicker
      f.input :verified_at, as: :datepicker
    end

    f.actions
  end

  show do |timeline_event|
    attributes_table do
      row :startup
      row :title
      row :timeline_event_type
      row :description
      row :iteration
      row :image
      row :event_on
      row :verified_at do
        if timeline_event.verified_at.present?
          "#{timeline_event.verified_at} (#{link_to 'Unverify', unverify_admin_timeline_event_path, method: :post, data: {confirm: 'Are you sure?'}})".html_safe
        else
          button_to('Unverified. Click to verify this event.', verify_admin_timeline_event_path)
        end
      end
    end

    panel 'Links' do
      render partial: 'links', locals: {timeline_event: timeline_event}
    end
  end
end
