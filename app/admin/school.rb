ActiveAdmin.register School do
  actions :all, except: %i[new create destroy]

  permit_params :logo_on_light_bg, :logo_on_dark_bg, :icon

  filter :name

  show do |school|
    attributes_table do
      row :name

      row :logo_on_light_bg do
        if school.logo_on_light_bg.attached?
          link_to(school.logo_on_light_bg) do
            image_tag(url_for(school.logo_variant(:thumb)))
          end
        else
          em('Not attached')
        end
      end

      row :logo_on_dark_bg do
        if school.logo_on_dark_bg.attached?
          link_to(school.logo_on_dark_bg) do
            image_tag(url_for(school.logo_variant(:thumb, background: :dark)))
          end
        else
          em('Not attached')
        end
      end

      row :icon do
        if school.icon.attached?
          link_to(school.icon) do
            image_tag(url_for(school.icon_variant(:thumb)))
          end
        else
          em('Not attached')
        end
      end

      row :id
      row :founder_tags do
        linked_tags(school.founder_tags)
      end
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs 'School Details' do
      f.input :name, input_html: { disabled: true }
      f.input :logo_on_light_bg, as: :file, hint: f.object.logo_on_light_bg.attached? ? "Upload another file to replace #{f.object.logo_on_light_bg.filename}" : nil
      f.input :logo_on_dark_bg, as: :file, hint: f.object.logo_on_dark_bg.attached? ? "Upload another file to replace #{f.object.logo_on_dark_bg.filename}" : nil
      f.input :icon, as: :file, hint: f.object.icon.attached? ? "Upload another file to replace #{f.object.icon.filename}" : nil
    end

    f.actions
  end
end
