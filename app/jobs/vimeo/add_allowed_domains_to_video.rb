module Vimeo
  class AddAllowedDomainsToVideo < ApplicationJob
    queue_as :default

    def perform(school, video_id)
      school.domains.pluck(:fqdn).map do |fqdn|
        api_service = ApiService.new(school)
        api_service.add_allowed_domain_to_video(fqdn, video_id)
      end
    end
  end
end
