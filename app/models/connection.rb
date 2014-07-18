class Connection < ActiveRecord::Base
  DIRECTION_SV_TO_USER = 'sv_to_user'
  DIRECTION_USER_TO_SV = 'user_to_sv'

  # This model maintains the many-to-many relationship between Users and 'Contact' Users.
  belongs_to :user
  belongs_to :contact, class_name: 'User', foreign_key: 'contact_id'

  # Make sure that connection entry is unique to contact and user.
  validates_presence_of :user_id
  validates_presence_of :contact_id
  validates_uniqueness_of :contact_id, scope: :user_id

  # Direction of connection is either from SV to user or from user to SV.
  validates :direction, presence: true, inclusion: { in: [DIRECTION_SV_TO_USER, DIRECTION_USER_TO_SV] }

  after_create :send_notification_for_sv_connection

  private

  def send_notification_for_sv_connection
    if direction == DIRECTION_SV_TO_USER
      UserPushNotifyJob.new.async.perform(user.id, :create_connection, I18n.t('notifications.create_connection', fullname: contact.fullname),
        contact.contact_fields
      )
    end
  end
end
