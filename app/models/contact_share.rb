# Stores records of contacts between SV and the userbase.
class ContactShare < ActiveRecord::Base
  SHARE_DIRECTION_SV_TO_USER = 'sv_to_user'
  SHARE_DIRECTION_USER_TO_SV = 'user_to_sv'

  # Make sure that contact share entry is unique to contact and user.
  validates_uniqueness_of :contact_id, scope: :user_id

  # Share direction is either from SV to user or from user to SV.
  validates :share_direction, inclusion: { in: [SHARE_DIRECTION_SV_TO_USER, SHARE_DIRECTION_USER_TO_SV] }
end
