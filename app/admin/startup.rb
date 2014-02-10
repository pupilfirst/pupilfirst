ActiveAdmin.register Startup do
  menu :parent => "Startup"

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

  form :partial => "admin/startups/form"
  # form do |f|
  #   f.inputs do
  #     f.input :name
  #     f.input :logo
  #     f.input :website
  #     f.input :pitch, :input_html => { :maxlength => nil  }
  #     f.input :about, :input_html => { :maxlength => nil  }
  #     f.input :twitter_link
  #     f.input :facebook_link
  #     f.input :email
  #     f.input :phone
  #   end
  #   f.inputs do
  #     f.input :categories, :collection => Category.startup_category
  #     f.input :founders, :collection => User.all
  #   end
  #   f.actions
  # end
  permit_params :name, :pitch, :website, :about, :email, :phone, :logo, :facebook_link, :twitter_link, {category_ids: []}, {founder_ids: []}, {founders_attributes: [:id, :fullname, :email, :username, :avatar, :remote_avatar_url, :title, :linkedin_url, :twitter_url, :skip_password]}, :created_at, :updated_at

end
