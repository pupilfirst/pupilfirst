ActiveAdmin.register User do


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
  controller do
    newrelic_ignore
  end

  permit_params :username, :fullname, :email, :remote_avatar_url, :avatar

  form do |f|
    f.inputs "User details" do
      f.input :username
      f.input :email
      f.input :fullname
      f.input :avatar, as: :file
      f.input :remote_avatar_url
    end
    f.actions
  end
end
