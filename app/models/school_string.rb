class SchoolString < ApplicationRecord
  class Key
    class << self
      def key
        name.demodulize.underscore
      end

      def for(school)
        SchoolString.find_by(school: school, key: key)&.value
      end

      def saved?(school)
        SchoolString.exists?(school: school, key: key)
      end
    end
  end

  class CoachesIndexSubheading < Key; end
  class LibraryIndexSubheading < Key; end
  class EmailAddress < Key; end
  class Address < Key; end
  class PrivacyPolicy < Key; end
  class TermsAndConditions < Key; end

  # School description shouldn't contain double-quotes, since this is used as meta-description in layouts.
  class Description < Key; end

  VALID_KEYS = [
    CoachesIndexSubheading, LibraryIndexSubheading, EmailAddress, Address, PrivacyPolicy, TermsAndConditions, Description
  ].map(&:key).freeze

  belongs_to :school

  validates :key, presence: true, inclusion: { in: VALID_KEYS }
  validates :value, presence: true
end
