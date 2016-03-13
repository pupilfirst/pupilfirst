ActiveAdmin.register TimelineEventType do
  menu parent: 'Timeline Events'

  index do
    selectable_column
    column :key
    column :role
    column :title
    actions
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

  permit_params :key, :role, :title, :sample_text, :badge, :copy_badge_from, :proof_required, :suggested_stage, :major
end
