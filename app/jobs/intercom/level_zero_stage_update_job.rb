module Intercom
  class LevelZeroStageUpdateJob < ApplicationJob
    queue_as :default

    def perform(founder, stage)
      intercom = IntercomClient.new
      user = intercom.find_or_create_user(email: founder.email, name: founder.name)
      intercom.update_user(user, stage: stage)
    end
  end
end
