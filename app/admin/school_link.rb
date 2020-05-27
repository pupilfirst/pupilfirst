ActiveAdmin.register SchoolLink do
  permit_params :school_id, :title, :url, :kind

  menu parent: 'Schools'

  filter :school
  filter :kind, as: :select, collection: SchoolLink::VALID_KINDS
  filter :title
  filter :url

  index do
    id_column

    column :school
    column :kind
    column :title
    column :url

    actions
  end

  form do |f|
    f.inputs 'School Link Details' do
      f.input :school
      f.input :title
      f.input :kind, as: :select, collection: SchoolLink::VALID_KINDS
      f.input :url
    end

    f.actions
  end
end
