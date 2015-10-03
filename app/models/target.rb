class Target < ActiveRecord::Base
  belongs_to :startup
  belongs_to :assigner, class_name: 'AdminUser'
  belongs_to :timeline_event_type

  # See en.yml's role
  def self.valid_roles
    %w(team) + User.valid_roles
  end

  validates_presence_of :startup_id, :assigner_id, :timeline_event_type_id, :role, :title, :short_description,
    :resource_url
  validates_inclusion_of :role, in: valid_roles

  def status
    related_event = startup.timeline_events.find_by(timeline_event_type: timeline_event_type)

    if related_event.present?
      if related_event.verified?
        'completed'
      else
        'in_progress'
      end
    else
      'pending'
    end
  end
end
