ActiveAdmin.register Request do
  actions :index, :destroy

  controller do
    newrelic_ignore
  end

  filter :created_at

  index do
    selectable_column

    column :user do |request|
      sv_id_link(request.user)
    end

    column :startup do |request|
      startup_link(request.user.try(:startup))
    end

    column :body do |request|
      simple_format request.body
    end

    column :created_at

    actions
  end
end
