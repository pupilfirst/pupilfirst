ActiveAdmin.register School do
  actions :all, except: %i[new edit update create destroy]

  controller do
    include DisableIntercom
  end

  filter :name
end
