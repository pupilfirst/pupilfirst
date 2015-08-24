ActiveAdmin.register TimelineEventType do
menu parent: 'Startups'
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :key, :title, :sample_text, :badge, :copy_badge_from
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if resource.something?
#   permitted
# end

  index do
    selectable_column
    column :key
    column :title
    column :badge
    actions
  end

  form do |f|
    f.inputs 'Event Details' do
      f.input :key
      f.input :title
      f.input :sample_text
    end
    f.inputs 'Upload new badgre OR re-use existing badge' do
      f.input :badge
      f.input :copy_badge_from, collection: TimelineEventType.all
    end
    f.actions
  end


end
