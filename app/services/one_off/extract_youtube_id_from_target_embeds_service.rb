module OneOff
  class ExtractYoutubeIdFromTargetEmbedsService
    include Loggable

    def execute
      targets_with_embed.each do |target|
        embed_value, embed_type = target.video_embed.present? ? [target.video_embed, :video] : [target.slideshow_embed, :slideshow]

        matcher = embed_value.match(%r{youtube.com/embed/(?<id>[a-zA-Z0-9\-_]+)\??})
        youtube_video_id = matcher[:id] if matcher.present?

        next if youtube_video_id.blank?

        log "Target ##{target.id}'s #{embed_type} embed will be updated with YouTube Video ID: #{youtube_video_id}"

        target.public_send("#{embed_type}_embed=", nil)
        target.youtube_video_id = youtube_video_id
        target.save!
      end

      true
    end

    private

    def targets_with_embed
      Target.live.where.not(slideshow_embed: [nil, '']).or(Target.where.not(video_embed: [nil, ''])).distinct
    end
  end
end
