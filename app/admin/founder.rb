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
  scope :inactive

  filter :startup_batch_id_eq, as: :select, collection: proc { Batch.all }, label: 'Batch'
  filter :email
  filter :first_name
  filter :last_name

  filter :ransack_tagged_with,
    as: :select,
    multiple: true,
    label: 'Tags',
    collection: -> { Founder.tag_counts_on(:tags).pluck(:name).sort }

  filter :roles_cont, as: :select, collection: Founder.valid_roles, label: 'Role'
  filter :university
  filter :roll_number

  permit_params :first_name, :last_name, :email, :remote_avatar_url, :avatar, :startup_id, :slug, :about,
    :slack_username, :skip_password, :born_on, :startup_admin, :communication_address, :identification_proof,
    :phone, :invitation_token, :university_id, :roll_number, :course, :semester, :year_of_graduation,
    :twitter_url, :linkedin_url, :personal_website_url, :blog_url, :facebook_url, :angel_co_url, :github_url, :behance_url,
    { roles: [] }, :tag_list, :gender, :skype_id

  batch_action :tag, form: proc { { tag: Founder.tag_counts_on(:tags).pluck(:name) } } do |ids, inputs|
    Founder.where(id: ids).each do |founder|
      founder.tag_list.add inputs[:tag]
      founder.save!
    end

    redirect_to collection_path, alert: 'Tag added!'
  end

  # Customize the index. Let's show only a small subset of the tons of fields.
  index do
    selectable_column
    column :fullname

    column :targets do |founder|
      if founder.targets.present?
        ol do
          hide_some_targets = founder.targets.count >= 5

          founder.targets.order('updated_at DESC').each_with_index do |target, index|
            fa_icon = if target.done?
              'fa-check'
            elsif target.expired?
              'fa-times'
            else
              'fa-circle-o'
            end

            li class: (index >= 3 && hide_some_targets ? "hide admin-founder-#{founder.id}-hidden-target" : '') do
              link_to " #{target.title}", [:admin, target], class: "fa #{fa_icon} no-text-decoration"
            end
          end

          if hide_some_targets
            li do
              a class: 'admin-founder-targets-show-link fa fa-chevron-circle-down', 'data-founder-id' => founder.id do
                ' Show all targets'
              end
            end
          end
        end
      end
    end

    column :email

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

    column :karma_points do |founder|
      points = founder.karma_points.where('created_at > ?', Date.today.beginning_of_week).sum(:points)
      link_to points, admin_karma_points_path(q: { founder_id_eq: founder.id })
    end

    actions
  end

  csv do
    column :email
    column :first_name
    column :last_name

    column :product do |founder|
      founder.startup&.product_name
    end

    column :batch do |founder|
      founder.startup&.batch&.to_label
    end

    column :roles do |founder|
      founder.roles.join ', '
    end

    column :phone
    column :gender
    column :born_on
    column :communication_address
    column :about

    column :university do |founder|
      founder.university&.name
    end

    column :roll_number
    column :course
    column :semester
    column :year_of_graduation

    column :slack_username
    column(:skype_username, &:skype_id)

    column :startup_admin?
    column :slug

    column :resume_url
    column :linkedin_url
    column :twitter_url
    column :personal_website_url
    column :blog_url
    column :facebook_url
    column :angel_co_url
    column :github_url
    column :behance_url
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

      row :tags do |founder|
        linked_tags(founder.tags)
      end

      row :roles do |founder|
        founder.roles.map do |role|
          t("role.#{role}")
        end.join ', '
      end

      row :product_name do |founder|
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

      row :startup_admin

      row :registration_status do |founder|
        if founder.startup_token.present?
          if founder.startup_admin?
            "This founder is team lead of a startup that hasn't completed registration."
          else
            team_lead = Founder.find_by(startup_admin: true, startup_token: founder.startup_token)

            "This founder is part of a team led by #{link_to team_lead.display_name, admin_founder_path(team_lead)}, "\
            "who hasn't completed startup registration.".html_safe
          end
        elsif founder.phone.blank?
          "This founder's startup has registered, but his/ her registration is incomplete."
        else
          'Registration is complete.'
        end
      end

      row :about
      row :born_on
      row :slack_username
      row :slack_user_id
      row 'Skype Id' do
        founder.skype_id
      end

      row :resume_url do |founder|
        link_to(founder.resume_url, founder.resume_url) if founder.resume_url.present?
      end

      row :phone
      row :unconfirmed_phone
      row :phone_verification_code
      row :communication_address

      row :designation

      row :identification_proof do
        if founder.identification_proof.present?
          link_to founder.identification_proof.url do
            image_tag founder.identification_proof.thumb.url
          end
        end
      end

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

    if founder.targets.present?
      div do
        table_for founder.targets.order('created_at DESC') do
          caption 'Linked Targets'
          column 'Target' do |target|
            a href: admin_target_path(target) do
              target.title
            end
          end

          column :role do |target|
            t("role.#{target.role}")
          end

          column :status do |target|
            if target.expired?
              'Expired'
            else
              t("target.status.#{target.status}")
            end
          end

          column :assigner
          column :created_at
        end
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

  action_item :invite_team, only: :index do
    link_to 'Invite team', invite_team_form_admin_founders_path
  end

  action_item :invite_founder, only: :index do
    link_to 'Invite founder', invite_founder_form_admin_founders_path
  end

  action_item :view_targets, only: :show do
    link_to 'View Targets', admin_targets_path(q: { assignee_type_eq: 'Founder', assignee_id_eq: founder.id })
  end

  collection_action :invite_team_form do
  end

  collection_action :invite_founder_form do
  end

  collection_action :send_team_invites, method: :post do
    invited_to_batch = Batch.find params[:invited_to_batch]
    team_lead = params[:team_lead_email]
    founders = params[:founder_emails].reject(&:blank?)

    # Team lead is mandatory.
    if team_lead.blank?
      flash[:error] = 'Team lead is mandatory.'
      redirect_to :back
      return
    end

    # There should be at least two other founders.
    if founders.count < 2
      flash[:error] = 'Two other founders, besides the team lead are required.'
      redirect_to :back
      return
    end

    # Check whether all the emails look OK.
    if ([team_lead] + founders).select { |founder_email| !(founder_email =~ /@/) }.present?
      flash[:error] = 'Not all email addresses look right. Please enter emails again.'
      redirect_to :back
      return
    end

    # None of the founders should already exist.
    if ([team_lead] + founders).select { |founder_email| Founder.find_by email: founder_email }.present?
      flash[:error] = 'None of the supplied email addresses should be of existing founders.'
      redirect_to :back
      return
    end

    # Set the same startup token for all invites. This'll let us associate them when team lead creates startup.
    startup_token = Time.now.in_time_zone('Asia/Calcutta').strftime('%a, %e %b %Y, %I:%M:%S %p IST')

    # Invite team lead.
    Founder.invite! email: team_lead, invited_batch: invited_to_batch, startup_token: startup_token, startup_admin: true

    # Invite founders one by one.
    founders.each do |founder_email|
      Founder.invite! email: founder_email, invited_batch: invited_to_batch, startup_token: startup_token
    end

    flash[:success] = 'Invitations successfully sent!'
    redirect_to action: :index
  end

  collection_action :send_founder_invite, method: :post do
    startup = Startup.find_by id: params.dig(:invite, :startup_id)
    token = params.dig(:invite, :startup_token)
    email = params.dig(:invite, :email)

    # Either startup or token should be picked.
    if (startup.blank? && token.blank?) || (startup.present? && token.present?)
      flash[:error] = 'Only one of startup or token should be picked.'
      redirect_to :back
      return
    end

    # Check whether the emails look OK.
    unless email =~ /@/
      flash[:error] = "That email address doesn't look right. Please enter it again."
      redirect_to :back
      return
    end

    # The email address shouldn't already be in use.
    if Founder.find_by(email: email).present?
      flash[:error] = 'That email address is already registered with us.'
      redirect_to :back
      return
    end

    founder_params = if startup.present?
      { startup: startup, invited_batch: startup.batch }
    else
      team_lead = Founder.find_by startup_admin: true, startup_token: token
      { startup_token: token, invited_batch: team_lead.invited_batch }
    end.merge(email: email)

    # Invite the founder
    Founder.invite! founder_params

    flash[:success] = 'Invitation successfully sent!'
    redirect_to action: :index
  end

  form partial: 'admin/founders/form'
end
