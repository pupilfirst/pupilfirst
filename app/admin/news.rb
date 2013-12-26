ActiveAdmin.register News do


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

  permit_params :title, :body, :user_id, :featured, :youtube_id, :remote_picture_url, :picture, :published_at, :published_at_date, :published_at_time_hour, :published_at_time_minute, :category_id


  form do |f|
    f.inputs "Details" do
      f.input :title
      f.input :body, as: :html_editor
      f.input :author
      f.input :featured
      f.input :category, collection: Category.news_category, prompt: "Choose a Category"
      f.input :published_at, as: :just_datetime_picker
      f.input :youtube_id, label: "youtube_id", hint: "Eg in \"https://www.youtube.com/watch?v=foobar\" ID is foobar"
      f.input :picture, as: :file
      f.input :remote_picture_url, placeholder: "publicly accesable url"
    end
    f.actions
  end

  show do |event|
    attributes_table do
      row :title
      row :image do
        link_to(image_tag(event.picture_url(:thumb)), event.picture_url)
      end
      row :featured
      row :author
      row :category
      row :youtube_id do
        link_to(image_tag(event.youtube_thumbnail_url(:mid)), "http://youtube.com/watch?v=#{event.youtube_id}") if event.youtube_id.present?
      end
      row :body do
        simple_format event.body
      end
      row :published_at
    end
    active_admin_comments
  end

end
