ActiveAdmin.register DbConfig do

  form do |f|
    f.inputs "Details" do
      f.input :key, collection: DbConfig::VARS.map { |k,v| [v, k] }, include_blank: false
      f.input :value
    end
    f.actions
  end

  permit_params :key, :value
end
