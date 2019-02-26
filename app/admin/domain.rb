ActiveAdmin.register Domain do
  actions :all, except: %i[new create]

  permit_params :primary

  controller do
    include DisableIntercom
  end

  menu parent: 'Schools'

  filter :fqdn
  filter :school
  filter :primary

  index do
    id_column

    column :school
    column :primary
    column :fqdn

    actions
  end

  form do |f|
    f.inputs 'Domain Details' do
      f.input :school, input_html: { disabled: true }, required: false
      f.input :fqdn, input_html: { disabled: true }
      f.input :primary
    end

    f.actions
  end
end
