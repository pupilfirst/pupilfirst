class CreateVimeoVideoMutator < ApplicationQuery
  include AuthorizeAuthor

  property :size, validates: { presence: true }
  property :title, validates: { length: { maximum: 250 } }
  property :description, validates: { length: { maximum: 500 } }

  def create_vimeo_video
    vimeo_api = Vimeo::ApiService.new(current_school)
    response = vimeo_api.create_video(size, title, description)

    if response[:error_code].present?
      if response[:developer_message].present?
        errors[:base] << response[:developer_message]
      else
        errors[:base] << "Encountered error with code #{response[:error_code]} when trying to create a Vimeo video."
      end
      nil
    else
      video_id = response[:uri].split('/')[-1]
      Vimeo::AddAllowedDomainsToVideo.perform_later(current_school, video_id)

      {
        upload_link: response[:upload][:upload_link],
        link: response[:link]
      }
    end
  end

  private

  def resource_school
    current_school
  end
end
