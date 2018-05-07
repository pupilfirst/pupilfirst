module Intercom
  class FounderSkillUpdateJob < ApplicationJob
    queue_as :low_priority

    class << self
      attr_writer :mock

      def mock?
        defined?(@mock) ? @mock : Rails.env.test?
      end
    end

    def perform(founder, skill)
      return true
      # rubocop:disable Lint/UnreachableCode
      return if self.class.mock?

      intercom = IntercomClient.new
      user = intercom.find_or_create_user(email: founder.email, name: founder.name)
      intercom.update_user(user, skill: skill)
      # rubocop:enable Lint/UnreachableCode
    end
  end
end
