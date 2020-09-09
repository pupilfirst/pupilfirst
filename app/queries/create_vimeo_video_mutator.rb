class CreateVimeoVideoMutator < ApplicationQuery
  include AuthorizeAuthor
  
  property :size, validates: { presence: true }
  
  def create_vimeo_video
    vimeo_api = Vimeo::ApiService.new(current_school)
    response = vimeo_api.create_video(size)

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
