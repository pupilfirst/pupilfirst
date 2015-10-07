ActiveAdmin.register Resource do
  menu parent: 'Startups'

  permit_params :title, :description, :file, :thumbnail, startup_ids: []

  preserve_default_filters!
  filter :startup,
    collection: Startup.batched,
    label: 'Product',
    member_label: proc { |startup| "#{startup.product_name}#{startup.name.present? ? " (#{startup.name})" : 's'}" }

  index do
    selectable_column

    column 'Share count' do |resource|
      resource.startups.count
    end

    column :title
    actions
  end

  show do
    attributes_table do
      row 'Shared with' do |resource|
        if resource.startups.present?
          table do
            resource.startups.each do |startup|
              tr do
                td do
                  a href: admin_startup_url(startup) do
                    span startup.product_name

                    if startup.name.present?
                      span(class: 'wrap-with-paranthesis') { startup.name }
                    end
                  end
                end
              end
            end
          end
        else
          em 'Not shared'
        end
      end

      row :title
      row :description

      row :thumbnail do |resource|
        img src: resource.thumbnail_url
      end

      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs 'Resource details' do
      f.input :startups,
        as: :select,
        member_label: proc { |startup| "#{startup.product_name}#{startup.name.present? ? " (#{startup.name})" : ''}" }
      f.input :file, as: :file
      f.input :thumbnail, as: :file
      f.input :title
      f.input :description
    end

    f.actions
  end
end
