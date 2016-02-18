ActiveAdmin.register Founder do
  controller do
    def scoped_collection
      super.includes :university, :startup
    end

    def find_resource
      scoped_collection.friendly.find(params[:id])
    end
  end

  menu label: 'Founders'

  scope :all
  scope :batched
  scope :missing_startups

  # Customize the index. Let's show only a small subset of the tons of fields.
  index do
    selectable_column
    actions
    column :email
    column :fullname

    column :product_name do |founder|
      if founder.startup.present?
        a href: admin_startup_path(founder.startup) do
          span do
            founder.startup.try(:product_name)
          end

          if founder.startup.name.present?
            span do
              " (#{founder.startup.name})"
            end
          end
        end
      end
    end

    column :university

    column :karma_points do |founder|
      points = founder.karma_points.where('created_at > ?', Date.today.beginning_of_week).sum(:points)
      link_to points, admin_karma_points_path(q: { founder_id_eq: founder.id })
    end
  end

  member_action :remove_from_startup, method: :post do
    founder = Founder.friendly.find params[:id]
    founder.remove_from_startup!
    redirect_to action: :show
  end

  show do
    attributes_table do
      row :slug
      row :email
      row :fullname

      row :roles do |founder|
        founder.roles.map do |role|
          t("role.#{role}")
        end.join ', '
      end

      row :product_name do |founder|
        if founder.startup.present?
          if founder.startup.present?
            a href: admin_startup_path(founder.startup) do
              span do
                founder.startup.try(:product_name)
              end

              if founder.startup.name.present?
                span do
                  " (#{founder.startup.name})"
                end
              end
            end

            span class: 'wrap-with-paranthesis' do
              link_to 'Remove from Startup', remove_from_startup_admin_founder_path, method: :post, data: { confirm: 'Are you sure?' }
            end
          end
        end
      end

      row :startup_admin
      row :about
      row :born_on
      row :slack_username
      row :slack_user_id

      row :resume_url do |founder|
        link_to(founder.resume_url, founder.resume_url) if founder.resume_url.present?
      end

      row :phone
      row :unconfirmed_phone
      row :phone_verification_code
      row :communication_address

      row :designation
      row :university
      row :roll_number

      row :college_identification do
        if founder.college_identification.present?
          link_to founder.college_identification.url do
            image_tag founder.college_identification.thumb.url
          end
        end
      end

      row :course
      row :semester
      row :year_of_graduation
    end

    panel 'Social links' do
      attributes_table_for founder do
        row :twitter_url
        row :facebook_url
        row :linkedin_url
        row :personal_website_url
        row :blog_url
        row :angel_co_url
        row :github_url
        row :behance_url
      end
    end

    panel 'Devise details' do
      attributes_table_for founder do
        row :confirmed_at
        row :reset_password_sent_at
        row :sign_in_count
        row :current_sign_in_at
        row :last_sign_in_at
      end
    end
  end

  action_item :feedback, only: :show, if: proc { Founder.friendly.find(params[:id]).startup.present? } do
    link_to(
      'Record New Feedback',
      new_admin_startup_feedback_path(
        startup_feedback: { startup_id: Founder.friendly.find(params[:id]).startup.id, reference_url: startup_url(Founder.friendly.find(params[:id]).startup) }
      )
    )
  end

  action_item :public_slack_messages, only: :show, if: proc { Founder.friendly.find(params[:id]).slack_username.present? } do
    link_to 'Public Slack Messages', admin_public_slack_messages_path(q: { founder_id_eq: params[:id] })
  end

  action_item :new_invite, only: :index do
    link_to 'Send New Invite', invite_form_admin_founders_path
  end

  collection_action :invite_form do
  end

  collection_action :send_invite, method: :post do
    email = params[:founder][:email]

    # do not send invites to already registered founders
    if Founder.find_by(email: email).present?
      flash.now[:error] = 'A founder with this email id already exists!'
      redirect_to :back
      return
    end

    if email =~ /@/ && Founder.invite!(email: email)
      flash.now[:success] = 'Invitation successfully sent!'
      redirect_to action: :index
    else
      flash.now[:error] = 'Error in sending invitation! Please ensure the Email address is valid and try again.'
      redirect_to :back
    end
  end

  # Customize the filter options to reduce the size.
  filter :email
  filter :first_name
  filter :last_name
  filter :roles_cont, as: :select, collection: Founder.valid_roles, label: 'Role'
  filter :university
  filter :roll_number

  form partial: 'admin/founders/form'

  permit_params :first_name, :last_name, :email, :remote_avatar_url, :avatar, :startup_id, :slug, :about,
    :slack_username, :skip_password, :born_on, :startup_admin, :communication_address,
    :phone, :invitation_token, :university_id, :roll_number, :course, :semester, :year_of_graduation,
    :twitter_url, :linkedin_url, :personal_website_url, :blog_url, :facebook_url, :angel_co_url, :github_url, :behance_url,
    roles: []
end
