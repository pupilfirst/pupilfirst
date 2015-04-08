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
    column :is_student
    column :startup_admin
    column :phone_verified
  end

  member_action :remove_from_startup, method: :post do
    user = User.find params[:id]
    user.remove_from_startup!
    redirect_to action: :show
  end

  member_action :send_founder_profile_reminder, method: :post do
    user = User.find params[:id]
    push_message = 'Please make sure you complete your profile to help us connect you to mentors and investors.'

    # Send push message.
    UserPushNotifyJob.perform_later(user.id, 'founder_profile_reminder', push_message)

    # Send email.
    UserMailer.reminder_to_complete_founder_profile(user).deliver_later

    redirect_to action: :show
  end

  show do
    attributes_table do
      row :id
      row :email
      row :fullname
      row :pending_startup

      row :startup do |f|
        if f.startup
          "#{link_to f.startup.name, admin_startup_path(f.startup)} (#{link_to 'Remove from Startup', remove_from_startup_admin_user_path, { method: :post, data: { confirm: 'Are you sure?' } }})".html_safe
        end
      end

      row :startup_admin
      row :is_founder
      row :born_on
      row :phone
      row :phone_verified
      row :communication_address
      row :district
      row :state
      row 'PIN Code' do
        user.pin
      end
      row :company
      row :designation
      row :is_student
      row :college
      row :year_of_graduation
      row :title
      row :years_of_work_experience
    end

    attributes_table do
      row :confirmed_at
      row :reset_password_sent_at
      row :sign_in_count
      row :current_sign_in_at
      row :last_sign_in_at
    end

    panel 'Emails and Notifications' do
      link_to('Reminder to complete founder profile', send_founder_profile_reminder_admin_user_path, method: :post, data: { confirm: 'Are you sure you wish to send notification and email?' })
    end
  end

  # Customize the filter options to reduce the size.
  filter :email
  filter :fullname
  filter :phone
  filter :is_founder
  filter :is_student
  filter :phone_verified
  # TODO: The check_boxes filter is disabled because of some bug with activeadmin. Check and enable when required.
  # filter :categories, as: :check_boxes, collection: proc { Category.user_category }
  filter :categories, collection: proc { Category.user_category }

  scope :missing_startups

  form partial: 'admin/users/form'

  permit_params :username, :fullname, :email, :remote_avatar_url, :avatar, :startup_id, :twitter_url, :linkedin_url,
    :title, :skip_password, :born_on, :startup_admin, :communication_address, :district, :state, :pin,
    :phone, :phone_verified, :company, :invitation_token, :is_student, :college_id, :year_of_graduation,
    :years_of_work_experience, #:confirmed_at,
    { category_ids: [] }
end
