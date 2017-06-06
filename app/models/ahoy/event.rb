module Ahoy
  class Event < ApplicationRecord
    self.table_name = 'ahoy_events'

    belongs_to :visit, optional: true
    belongs_to :user, polymorphic: true, optional: true
  end
end
