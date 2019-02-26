ActiveAdmin.register School do
  actions :all, except: %i[new create destroy]

  permit_params :logo

  controller do
    include DisableIntercom
  end

  filter :name

  show do |school|
    attributes_table do
      row :name

      row :logo do
        if school.logo.attached?
          link_to(school.logo) do
            image_tag(url_for(school.logo_variant(:thumb)))
          end
        else
          em('No logo attached')
        end
      end

      row :id
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs 'School Details' do
      f.input :name, input_html: { disabled: true }
      f.input :logo, as: :file, hint: f.object.logo.attached? ? "Upload another file to replace #{f.object.logo.filename}" : nil
    end

    f.actions
  end
end
