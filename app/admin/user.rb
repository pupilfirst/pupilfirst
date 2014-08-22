ActiveAdmin.register User do
  controller do
    newrelic_ignore
  end

  menu label: 'SV Users'

  # Customize the index. Let's show only a small subset of the tons of fields.
  index do
    selectable_column
    actions
    column :email
    column :fullname
    column :phone
    column :is_founder
    column :is_contact
    column :is_student
    column :phone_verified
  end

  # Customize the filter options to reduce the size.
  filter :email
  filter :fullname
  filter :phone
  filter :is_founder
  filter :is_student
  filter :is_contact
  filter :phone_verified
  # TODO: The check_boxes filter is disabled because of some bug with activeadmin. Check and enable when required.
  # filter :categories, as: :check_boxes, collection: Category.user_category
  filter :categories, collection: Category.user_category

  form partial: 'admin/users/form'

  permit_params :username, :fullname, :email, :remote_avatar_url, :avatar, :startup_id, :twitter_url, :linkedin_url, :title, :skip_password, :born_on,
    :is_contact, :phone, :phone_verified, :company, :designation, :invitation_token, :confirmed_at,
    { category_ids: [] }
end
