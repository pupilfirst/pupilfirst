ActiveAdmin.register Location do


  # See permitted parameters documentation:
  # https://github.com/gregbell/active_admin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #  permitted = [:permitted, :attributes]
  #  permitted << :other if resource.something?
  #  permitted
  # end
  permit_params :latitude, :longitude, :title, :address


  form do |f|
    f.inputs "Details" do
      f.input :title
      f.input :address
      f.input :latitude, hint: "get it from http://dbsgeo.com/latlon/ for now."
      f.input :longitude, hint: "get it from http://dbsgeo.com/latlon/ for now."
    end
    f.actions
  end

end
