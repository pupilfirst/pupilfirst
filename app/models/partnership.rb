class Partnership < ActiveRecord::Base
  belongs_to :user
  belongs_to :startup

  validates_presence_of :user_id
  validates_presence_of :startup_id
  validates_presence_of :shares
  validates_presence_of :salary
  validates_presence_of :cash_contribution

  validates_uniqueness_of :user_id, scope: :startup_id
end
