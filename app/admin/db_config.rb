ActiveAdmin.register DbConfig do
  form do |f|
    f.inputs "Details" do
      f.input :key
      f.input :value
    end
    f.actions
  end

  permit_params :key, :value
end
