ActiveAdmin.register Feature do
  controller do
    include DisableIntercom
  end

  menu parent: 'Dashboard'

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs "Details" do
      f.input :key
      f.input :value
    end
    f.actions
  end

  permit_params :key, :value
end
