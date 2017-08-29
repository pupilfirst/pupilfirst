module Founders
  class UpdateSlackNameJob < ApplicationJob
    queue_as :default

    def perform(founder)
      Founders::UpdateSlackNameService.new(founder).execute
    end
  end
end
