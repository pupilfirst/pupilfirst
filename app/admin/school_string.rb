ActiveAdmin.register SchoolString do
  permit_params :school_id, :key, :value

  menu parent: 'Schools'

  index do
    id_column

    column :school
    column :key

    actions
  end

  show do |school_string|
    attributes_table do
      row :school
      row :key

      row :value do
        simple_format(school_string.value)
      end

      row :id
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs 'School String Details' do
      f.input :school
      f.input :key, as: :select, collection: SchoolString::VALID_KEYS
      f.input :value
    end

    f.actions
  end
end
