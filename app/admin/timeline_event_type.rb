ActiveAdmin.register TimelineEventType do
  controller do
    include DisableIntercom
  end

  menu parent: 'Timeline Events'

  filter :key
  filter :title
  filter :role, as: :select, collection: -> { TimelineEventType.valid_roles }
  filter :created_at

  index do
    selectable_column
    column :key
    column :role
    column :title
    actions
  end

  show do
    attributes_table do
      row :key
      row :title
      row :sample_text
      row :created_at
      row :updated_at
      row :badge
      row :role
      row :proof_required
      row :suggested_stage
      row :major
      row :archived do
        div class: 'timeline-event-type-show__archival-status' do
          timeline_event_type.archived ? 'Yes' : 'No'
        end

        div class: 'timeline-event-type-show__archive-button' do
          span do
            if !timeline_event_type.archived?
              button_to(
                'Archive Type',
                archive_type_admin_timeline_event_type_path(timeline_event_type: { archived: true }),
                method: :put, data: { confirm: 'Are you sure you want to archive this timeline event type?' }
              )
            else
              button_to(
                'Unarchive Type',
                archive_type_admin_timeline_event_type_path(timeline_event_type: { archived: false }),
                method: :put, data: { confirm: 'Are you sure you want to unarchive this timeline event type?' }
              )
            end
          end
        end
      end
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs 'Event Details' do
      f.input :key
      f.input :major
      f.input :suggested_stages, as: :check_boxes, collection: stages_collection, label: 'Suggested on stages'
      f.input :suggested_stage, as: :hidden
      f.input :role, as: :select, collection: TimelineEventType.valid_roles, include_blank: false
      f.input :title
      f.input :sample_text
      f.input :proof_required
    end

    f.inputs 'Upload new badge OR re-use existing badge' do
      f.input :badge
      f.input :copy_badge_from, collection: TimelineEventType.all
    end

    f.actions
  end

  permit_params :key, :role, :title, :sample_text, :badge, :copy_badge_from, :proof_required, :suggested_stage, :major, :archived

  member_action :archive_type, method: :put do
    timeline_event_type = TimelineEventType.find params[:id]
    params = permitted_params[:timeline_event_type]

    timeline_event_type.update!(archived: params[:archived])

    message_text = params[:archived] == 'true' ? 'archived' : 'unarchived'
    flash[:success] = "TimelineEventType #{message_text} successfully!"
    redirect_to action: :show
  end
end
