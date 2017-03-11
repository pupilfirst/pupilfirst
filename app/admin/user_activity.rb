ActiveAdmin.register UserActivity do
  include DisableIntercom

  menu parent: 'Dashboard'
  actions :index, :show

  filter :user, as: :select, collection: proc { User.joins(:user_activities).distinct.order(:email).pluck(:email, :id) }
  filter :activity_type, as: :select, collection: UserActivity.valid_activity_types
  config.sort_order = 'updated_at_desc'

  controller do
    def scoped_collection
      super.includes :user
    end
  end

  index do
    selectable_column

    column :user

    column('Founder') do |user_activity|
      user_activity.user.founder
    end

    column :activity_type
    column :created_at

    column('Activity Information') do |user_activity|
      case user_activity.activity_type
        when UserActivity::ACTIVITY_TYPE_RESOURCE_DOWNLOAD
          "Downloaded resource: #{Resource.find_by(id: user_activity.metadata['resource_id'])&.title || 'Info Missing'}"
        when UserActivity::ACTIVITY_TYPE_FACULTY_CONNECT_REQUEST
          "Connect Request with faculty: #{ConnectRequest.find_by(id: user_activity.metadata['connect_request_id'])&.connect_slot&.faculty&.name || 'Info Missing'}"
        else
          'Unknown activity type'
      end
    end

    actions
  end

  show do
    attributes_table do
      row :id
      row :user

      row('Founder') do |user_activity|
        user_activity.user.founder
      end

      row :activity_type
      row :created_at
      row :updated_at
      row :metadata
    end
  end
end
