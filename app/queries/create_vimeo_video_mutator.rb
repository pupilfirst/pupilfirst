class CreateVimeoVideoMutator < ApplicationQuery
  include AuthorizeAuthor

  property :size, validates: { presence: true }

  def create_vimeo_video
    vimeo_api = Vimeo::ApiService.new(current_school)
    response = vimeo_api.create_video(size)
    video_id = response[:uri].split('/')[-1]
    Vimeo::AddAllowedDomainsToVideo.perform_later(current_school, video_id)

    {
      upload_link: response[:upload][:upload_link],
      link: response[:link]
    }
  end

  private

  def resource_school
    current_school
  end
end
