ActiveAdmin.register TimelineEventType do
  menu parent: 'Startups'

  index do
    selectable_column
    column :key
    column :role
    column :title
    column :badge
    actions
  end

  form do |f|
    f.inputs 'Event Details' do
      f.input :key
      f.input :suggested_stages, as: :check_boxes, collection: stages_collection, label: 'Suggested on stages'
      f.input :suggested_stage, as: :hidden
      f.input :role
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

  permit_params :key, :role, :title, :sample_text, :badge, :copy_badge_from, :proof_required, :suggested_stage
end
