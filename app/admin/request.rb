ActiveAdmin.register Request do
  controller do
    newrelic_ignore
  end

  filter :created_at

  index do
    selectable_column
    column :user do |request|
      name_link(request.user)
    end
    column :startup do |request|
      startup_link(request.user.startup)
    end
    column :body do |request|
      simple_format request.body
    end
    column :created_at
  end

  actions :index

  # permit_params :body, :user_id
end
