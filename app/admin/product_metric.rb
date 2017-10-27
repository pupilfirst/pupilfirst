ActiveAdmin.register ProductMetric do
  include DisableIntercom

  menu parent: 'Dashboard'

  permit_params :category, :value, :delta_period, :delta_value, :faculty_id

  filter :faculty_name, as: :string
  filter :category, as: :select, collection: -> { ProductMetric::VALID_CATEGORIES.keys }
  filter :value
  filter :delta_period
  filter :delta_value
  filter :assignment_mode, as: :select, collection: -> { ProductMetric.valid_assignment_modes }
  filter :created_at
  filter :updated_at

  index do
    selectable_column

    column :category
    column :value
    column :delta_period
    column :delta_value
    column :assignment_mode
    column :faculty
    column :created_at

    actions
  end

  before_save do |product_metric|
    product_metric.assignment_mode = ProductMetric::ASSIGNMENT_MODE_MANUAL
  end

  form do |f|
    f.inputs 'Product Metric Details' do
      f.input :faculty, collection: Faculty.team
      f.input :category, as: :select, collection: ProductMetric::VALID_CATEGORIES.keys
      f.input :value
      f.input :delta_period, label: 'Delta Period (months)', as: :select, collection: (1..12).to_a
      f.input :delta_value, label: 'Delta Value (override)'

      if f.object.delta_value.blank?
        li 'Adding a delta value will override the calculated value. This allows you to display any delta over the selected period.'
      end
    end

    if f.object.assignment_mode == ProductMetric::ASSIGNMENT_MODE_AUTOMATIC
      para do
        strong 'Updating this record will change the assignment mode to manual.'
      end
    end

    f.actions
  end
end
