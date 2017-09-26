ActiveAdmin.register Founder do
  include DisableIntercom

  controller do
    def scoped_collection
      super.includes :startup
    end

    def find_resource
      scoped_collection.friendly.find(params[:id])
    end
  end

  collection_action :search_founder do
    render json: Founders::Select2SearchService.search_for_founder(params[:q])
  end

  menu label: 'Founders'

  scope :admitted, default: true
  scope :inactive
  scope :level_zero
  scope :all

  filter :email
  filter :name

  filter :ransack_tagged_with,
    as: :select,
    multiple: true,
    label: 'Tags',
    collection: -> { Founder.tag_counts_on(:tags).pluck(:name).sort }

  filter :startup_level_id, as: :select, collection: Level.all.order(number: :asc)
  filter :startup_admission_stage, as: :select, collection: Startup.admission_stages, label: 'Admission Stage'
  filter :startup_id_null, as: :boolean, label: 'Without Startup'
  filter :roles_cont, as: :select, collection: Founder.valid_roles, label: 'Role'
  filter :college_name_contains
  filter :roll_number
  filter :created_at, label: 'Registered on'

  permit_params :name, :email, :hacker, :remote_avatar_url, :avatar, :startup_id, :slug, :about, :born_on,
    :communication_address, :identification_proof, :phone, :invitation_token, :college_id, :roll_number,
    :course, :semester, :year_of_graduation, :twitter_url, :linkedin_url, :personal_website_url, :blog_url,
    :angel_co_url, :github_url, :behance_url, :gender, :skype_id, :exited, :id_proof_number,
    :id_proof_type, :parent_name, :permanent_address, :address_proof, :income_proof,
    :letter_from_parent, roles: [], tag_list: []

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
    column :name

    if params['scope'] == 'level_zero'
      column :email
      column :phone
      column 'Skill' do |founder|
        if founder.hacker.nil?
          'Unknown'
        elsif founder.hacker
          founder.github_url.present? ? 'Hacker with Github' : 'Hacker'
        else
          'Hustler'
        end
      end
      column('Targets Completed', &:completed_targets_count)
      column 'Admission Stage' do |founder|
        founder.startup.admission_stage
      end
    else
      column :product_name, sortable: 'founders.startup_id' do |founder|
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

      column 'Total Karma (Personal)' do |founder|
        points = founder.karma_points&.sum(:points)
        if points.present?
          link_to points, admin_karma_points_path(q: { founder_id_eq: founder.id })
        else
          'Not Available'
        end
      end

      column 'Total Karma (Team)' do |founder|
        points = founder.startup&.karma_points&.sum(:points)
        if points.present?
          link_to points, admin_karma_points_path(q: { startup_id_eq: founder.startup&.id })
        else
          'Not Available'
        end
      end
    end

    actions
  end

  csv do
    if params['scope'] == 'level_zero'
      column :name
      column :email
      column :phone

      column 'Skill' do |founder|
        if founder.hacker.nil?
          'Unknown'
        elsif founder.hacker
          founder.github_url.present? ? 'Hacker with Github' : 'Hacker'
        else
          'Hustler'
        end
      end

      column :team_lead do |founder|
        founder.team_lead? ? 'Yes' : 'No'
      end

      column :stage do |founder|
        founder.startup&.admission_stage
      end

      column :stage_updated_at do |founder|
        founder.startup&.admission_stage_updated_at
      end

      column :reference

      column :college do |founder|
        founder.college.present? ? founder.college.name : founder.college_text
      end

      column :state do |founder|
        founder.college.present? ? founder.college.state.name : ''
      end

      column :created_at do |founder|
        founder.startup.created_at.to_date
      end

      column :tags do |founder|
        tags = ''
        founder.tags&.each do |tag|
          tags += tag.name + ';'
        end
        tags
      end

      column :admission_stage do |founder|
        founder.startup.admission_stage
      end
    else
      column :id
      column :email
      column :name

      column :team_lead do |founder|
        founder.team_lead? ? 'Yes' : 'No'
      end

      column :product do |founder|
        founder.startup&.product_name
      end

      column :company do |founder|
        founder.startup&.legal_registered_name
      end

      column :roles do |founder|
        founder.roles.join ', '
      end

      column 'Total Karma (Personal)' do |founder|
        founder.karma_points&.sum(:points) || 'Not Available'
      end

      column 'Total Karma (Team)' do |founder|
        founder.startup&.karma_points&.sum(:points) || 'Not Available'
      end

      column :phone
      column :gender
      column :born_on
      column :communication_address
      column :about

      column :college do |founder|
        founder.college&.name
      end

      column :university do |founder|
        founder.college&.university&.name
      end

      column :roll_number
      column :course
      column :semester
      column :year_of_graduation

      column :slack_username
      column(:skype_username) { |founder| founder.skype_id } # rubocop:disable Style/SymbolProc

      column :team_lead?
      column :slug

      column :resume, &:resume_link
      column :linkedin_url
      column :twitter_url
      column :personal_website_url
      column :blog_url
      column :angel_co_url
      column :github_url
      column :behance_url
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
      row :name
      row 'Skill' do |founder|
        if founder.hacker.nil?
          'Unknown'
        else
          founder.hacker ? 'Hacker' : 'Hustler'
        end
      end
      row :reference

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

      row :team_lead do
        founder.team_lead? ? 'Yes' : 'No'
      end
      row :about
      row :born_on
      row :parent_name
      row :gender
      row :slack_username
      row :slack_user_id
      row 'Skype Id' do
        founder.skype_id
      end

      row :phone
      row :communication_address

      row :designation
      row :college do |founder|
        if founder.college.present?
          link_to founder.college.name, admin_college_path(founder.college)
        elsif founder.college_text.present?
          founder.college_text
        end
      end

      row :university do |founder|
        university = founder.college&.university

        if university.present?
          link_to university.name, admin_university_path(university)
        end
      end

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
      row :backlog
      row :exited
      row :resume do |founder|
        link_to 'Download Resume', founder.resume_link if founder.resume_link.present?
      end
      active_admin_comments
    end

    panel 'Social links' do
      attributes_table_for founder do
        row 'Facebook Connected' do |founder|
          if founder.fb_access_token.present?
            status_tag('Connected', class: 'ok')

            span style: 'display:inline-block' do
              button_to 'Disconnect', disconnect_from_facebook_admin_founder_path(founder), method: :patch
            end
          else
            status_tag('Not Connected', class: 'no')
          end
        end
        row :fb_token_expires_at
        row :twitter_url
        row :linkedin_url
        row :personal_website_url
        row :blog_url
        row :angel_co_url
        row :github_url
        row :behance_url
      end
    end

    panel 'Admissions Data' do
      attributes_table_for founder do
        row :identification_proof do
          if founder.identification_proof.present?
            link_to 'Click here to open in new window', founder.identification_proof.url, target: '_blank'
          end
        end
        row :id_proof_type
        row :id_proof_number
        row :permanent_address
        row :address_proof do
          if founder.address_proof.present?
            link_to 'Click here to open in new window', founder.address_proof.url, target: '_blank'
          end
        end
        row :income_proof do
          if founder.income_proof.present?
            link_to 'Click here to open in new window', founder.income_proof.url, target: '_blank'
          end
        end
        row :letter_from_parent do
          if founder.letter_from_parent.present?
            link_to 'Click here to open in new window', founder.letter_from_parent.url, target: '_blank'
          end
        end
      end
    end
  end

  action_item :feedback, only: :show, if: proc { Founder.friendly.find(params[:id]).startup.present? } do
    startup = Founder.friendly.find(params[:id]).startup

    link_to(
      'Record New Feedback',
      new_admin_startup_feedback_path(
        startup_feedback: { startup_id: Founder.friendly.find(params[:id]).startup.id, reference_url: timeline_url(startup.id, startup.slug) }
      )
    )
  end

  action_item :impersonate, only: :show, if: proc { can? :impersonate, User } do
    link_to 'Impersonate', impersonate_admin_user_path(founder.user), method: :post
  end

  action_item :public_slack_messages, only: :show, if: proc { Founder.friendly.find(params[:id]).slack_username.present? } do
    link_to 'Public Slack Messages', admin_public_slack_messages_path(q: { founder_id_eq: params[:id] })
  end

  member_action :disconnect_from_facebook, method: :patch do
    founder = Founder.friendly.find(params[:id])
    Founders::FacebookService.new(founder).disconnect!
    redirect_to admin_founder_path(founder), alert: 'Founder profile disconnected from Facebook!'
  end

  form partial: 'admin/founders/form'
end
