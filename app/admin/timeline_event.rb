ActiveAdmin.register TimelineEvent do
  menu parent: 'Startups'
  permit_params :description, :iteration, :timeline_event_type_id, :image, :links, :event_on, :startup_id, :verified_at

  preserve_default_filters!
  filter :startup_batch, as: :select, collection: (1..10)

  scope :all
  scope :batched

  controller do
    def index
      params[:order] = 'updated_at_desc'
      super
    end
  end

  index do
    selectable_column
    actions
    column :timeline_event_type
    column :startup
    column :event_on

    column :verified_status do |timeline_event|
      if timeline_event.verified?
        "Verified on #{timeline_event.verified_at.strftime('%d/%m/%y')}"
      else
        timeline_event.verified_status
      end
    end
  end

  action_item :view, only: :show do
    link_to('View Timeline Entry', startup_url(timeline_event.startup, anchor: "event-#{timeline_event.id}"), target: '_blank')
  end

  action_item :feedback, only: :show do
    link_to(
      'Record New Feedback',
      new_admin_startup_feedback_path(
        startup_feedback: {
          startup_id: timeline_event.startup.id,
          reference_url: startup_url(timeline_event.startup, anchor: "event-#{timeline_event.id}")
        }
      )
    )
  end

  member_action :delete_link, method: :delete do
    timeline_event = TimelineEvent.find params[:id]
    timeline_event.links.delete_at(params[:link_index].to_i)
    timeline_event.save!

    flash[:notice] = 'Link Deleted!'

    redirect_to action: :show
  end

  member_action :add_link, method: :post do
    timeline_event = TimelineEvent.find params[:id]
    timeline_event.links << { title: params[:link_title], url: params[:link_url], private: params[:link_private] }
    timeline_event.save!

    flash[:success] = 'Link Added!'

    redirect_to action: :show
  end

  member_action :edit_link, method: :put do
    timeline_event = TimelineEvent.find params[:id]
    timeline_event.links[params[:link_index].to_i] = { title: params[:link_title], url: params[:link_url], private: params[:link_private] }
    timeline_event.save!

    flash[:success] = 'Link Updated!'

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

  member_action :mark_needs_improvement, method: :post do
    TimelineEvent.find(params[:id]).mark_needs_improvement!
    redirect_to action: :show
  end

  form do |f|
    f.inputs 'Event Details' do
      f.input :startup, include_blank: false
      f.input :timeline_event_type, include_blank: false
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
      row :timeline_event_type
      row :description
      row :iteration
      row :image
      row :event_on
      row :verified_status

      row :verified_at do
        if timeline_event.verified?
          span do
            "#{timeline_event.verified_at} "
          end

          span class: 'wrap-with-paranthesis' do
            link_to 'Unverify', unverify_admin_timeline_event_path, method: :post, data: { confirm: 'Are you sure?' }
          end
        elsif timeline_event.pending?
          span do
            button_to('Unverified. Click to verify this event.', verify_admin_timeline_event_path, form_class: 'inline-button')
          end

          span do
            button_to('Mark As Needs Improvement', mark_needs_improvement_admin_timeline_event_path, form_class: 'inline-button')
          end
        elsif timeline_event.needs_improvement?
          button_to('Unverified. Click to verify this event.', verify_admin_timeline_event_path)
        end
      end
    end

    render partial: 'links', locals: { timeline_event: timeline_event }
  end
end
