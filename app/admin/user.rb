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

  form do |f|
    f.inputs 'User details' do
      f.input :username
      f.input :email
      f.input :fullname
      f.input :twitter_url
      f.input :linkedin_url
      f.input :title
      f.input :born_on
      f.input :avatar, as: :file
      f.input :remote_avatar_url
      f.input :startup
      f.input :skip_password, as: :hidden, input_html: { value: true }
    end

    f.inputs 'Contact Details' do
      f.input :is_contact
      f.input :phone
      f.input :company
      f.input :designation
      f.input :phone_verified
      f.input :invitation_token
    end

    f.actions
  end

  permit_params :username, :fullname, :email, :remote_avatar_url, :avatar, :startup_id, :twitter_url, :linkedin_url, :title, :skip_password, :born_on,
    :is_contact, :phone, :phone_verified, :company, :designation, :invitation_token
end
