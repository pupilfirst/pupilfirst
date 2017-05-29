module Taggable
  extend ActiveSupport::Concern

  included do
    # Enable tagging.
    acts_as_taggable

    # Custom scope to allow AA to filter by intersection of tags.
    scope :ransack_tagged_with, ->(*tags) { tagged_with(tags) }
  end

  module ClassMethods
    def ransackable_scopes(_auth)
      %i[ransack_tagged_with]
    end
  end
end
