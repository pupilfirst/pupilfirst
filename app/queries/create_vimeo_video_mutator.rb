class CreateVimeoVideoMutator < ApplicationQuery
  include AuthorizeAuthor

  property :size, validates: { presence: true }
  property :title, validates: { length: { maximum: 250 } }
  property :description, validates: { length: { maximum: 500 } }

  def create_vimeo_video
    vimeo_api = Vimeo::ApiService.new(current_school)
    response = vimeo_api.create_video(size, title, description)
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
