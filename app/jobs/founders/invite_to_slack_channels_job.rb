module Founders
  class InviteToSlackChannelsJob < ApplicationJob
    def perform(founder)
      Founders::InviteToSlackChannelsService.new(founder).execute
    end
  end
end
