module OneOff
  class ResourceContentTypeUpdateService
    include Loggable
    def update
      resources_with_files = Resource.where.not(file: nil)
      updated_resources = 0
      log "There are #{resources_with_files.count} resources to update"
      resources_with_files.each do |resource|
        resource.update!(file_content_type: resource.file.content_type)
        updated_resources += 1
        sleep 0.25
        log "#{updated_resources} resources updated with content_type"
      end
    end
  end
end
