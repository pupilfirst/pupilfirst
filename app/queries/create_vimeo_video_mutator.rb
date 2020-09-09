class CreateVimeoVideoMutator < ApplicationQuery
  include AuthorizeAuthor
  
  property :target_id, validates: { presence: true }
  property :size, validates: { presence: true }
  
  def create_vimeo_video
    path = '/me/videos'
    data = {
      upload: {
        approach: 'tus',
        size: size
      },
      privacy: {
        embed: 'whitelist'
      }
    }

    api_service = Vimeo::ApiService.new(path, current_school)
    response = api_service.post(data)

    raise StandardError if response[:error_code]
    { 
      upload_link: response[:upload][:upload_link],
      uri: response[:uri]
    }
  end

  private 

  def resource_school
    current_school
  end
end
