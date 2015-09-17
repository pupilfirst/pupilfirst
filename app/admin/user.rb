ActiveAdmin.register User do
  controller do
    def scoped_collection
      super.includes :university, :startup
    end
  end

  menu label: 'SV Users'

  scope :all
  scope :batched
  scope :missing_startups

  # Customize the index. Let's show only a small subset of the tons of fields.
  index do
    selectable_column
    actions
    column :email
    column :fullname
    column :startup
    column :university

    column :karma_points do |user|
      points = user.karma_points.where('created_at > ?', Date.today.beginning_of_week).sum(:points)
      link_to points, admin_karma_points_path(q: { user_id_eq: user.id })
    end
  end

  index do
    h1 'something'
  end

  member_action :remove_from_startup, method: :post do
    user = User.find params[:id]
    user.remove_from_startup!
    redirect_to action: :show
  end

  member_action :send_founder_profile_reminder, method: :post do
    user = User.find params[:id]

    # Send email.
    UserMailer.reminder_to_complete_founder_profile(user).deliver_later

    redirect_to action: :show
  end

  show do
    attributes_table do
      row :id
      row :email
      row :fullname
      row :title

      row :startup do |f|
        if f.startup
          span do
            link_to f.startup.name, admin_startup_path(f.startup)
          end

          span class: 'wrap-with-paranthesis' do
            link_to 'Remove from Startup', remove_from_startup_admin_user_path, method: :post, data: { confirm: 'Are you sure?' }
          end
        end
      end

      row :startup_admin
      row :is_founder
      row :born_on
      row :phone
      row :unconfirmed_phone
      row :phone_verification_code
      row :communication_address
      row :district
      row :state

      row 'PIN Code' do
        user.pin
      end

      row :company
      row :designation
      row :university
      row :roll_number
    end

    attributes_table do
      row :confirmed_at
      row :reset_password_sent_at
      row :sign_in_count
      row :current_sign_in_at
      row :last_sign_in_at
    end

    panel 'Emails and Notifications' do
      link_to(
        'Reminder to complete founder profile',
        send_founder_profile_reminder_admin_user_path,
        method: :post,
        data: { confirm: 'Are you sure you wish to send notification and email?' }
      )
    end
  end

  action_item :feedback, only: :show do
    link_to(
      'Record New Feedback',
      new_admin_startup_feedback_path(
        startup_feedback: { startup_id: User.find(params[:id]).startup.id, reference_url: startup_url(User.find(params[:id]).startup) }
      )
    )
  end

  # Customize the filter options to reduce the size.
  filter :email
  filter :fullname
  filter :phone
  filter :unconfirmed_phone
  filter :is_founder
  filter :university
  filter :roll_number
  # TODO: The check_boxes filter is disabled because of some bug with activeadmin. Check and enable when required.
  # filter :categories, as: :check_boxes, collection: proc { Category.user_category }
  filter :categories, collection: proc { Category.user_category }

  form partial: 'admin/users/form'

  permit_params :fullname, :email, :remote_avatar_url, :avatar, :startup_id, :twitter_url, :linkedin_url, :slack_username,
    :title, :skip_password, :born_on, :startup_admin, :communication_address, :district, :state, :pin,
    :phone, :company, :invitation_token, :university_id, :roll_number, :year_of_graduation,
    :years_of_work_experience
end
