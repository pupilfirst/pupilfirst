module Vimeo
  class SetEmbedLinks < ApplicationJob
    queue_as :default

    def perform(current_school, video_id)
      current_school.domains.pluck(:fqdn).map do |fqdn|
        api_service = ApiService.new(current_school)
        api_service.create_embed_link("/videos/#{video_id}/privacy/domains/#{fqdn}")
      end
    end
  end
end
