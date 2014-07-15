class Connection < ActiveRecord::Base
  DIRECTION_SV_TO_USER = 'sv_to_user'
  DIRECTION_USER_TO_SV = 'user_to_sv'

  # This model maintains the many-to-many relationship between Users and 'Contact' Users.
  belongs_to :user
  belongs_to :contact, class_name: 'User', foreign_key: 'contact_id'

  # Make sure that connection entry is unique to contact and user.
  validates_uniqueness_of :contact_id, scope: :user_id

  # Direction of connection is either from SV to user or from user to SV.
  validates :direction, inclusion: { in: [DIRECTION_SV_TO_USER, DIRECTION_USER_TO_SV] }
end
