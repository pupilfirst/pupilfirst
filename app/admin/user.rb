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

  menu :label => "Startup Founders"

  permit_params :username, :fullname, :email, :remote_avatar_url, :avatar, :startup_id, :twitter_url, :linkedin_url, :title, :skip_password

  form do |f|
    f.inputs "User details" do
      f.input :username
      f.input :email
      f.input :fullname
      f.input :twitter_url
      f.input :linkedin_url
      f.input :title
      f.input :avatar, as: :file
      f.input :remote_avatar_url
      f.input :startup
      f.input :skip_password, as: :hidden, input_html:{value: true}
    end
    f.actions
  end
end
