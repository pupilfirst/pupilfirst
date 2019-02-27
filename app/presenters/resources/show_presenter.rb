module Resources
  class ShowPresenter < ApplicationPresenter
    def initialize(view_context, resource)
      @resource = resource

      super(view_context)
    end

    def play_video?
      @play_video ||= view.params[:watch].present? && @resource.stream?
    end

    def video_embed?
      @resource.video_embed.present?
    end

    def video_embed
      @resource.video_embed.html_safe
    end

    def stream_url
      view.url_for(@resource.file)
    end
  end
end
