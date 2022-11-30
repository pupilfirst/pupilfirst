module TimelineEvents
  class ShowPresenter < ApplicationPresenter
    def initialize(view_context, submission)
      super(view_context)

      @submission = submission
    end

    def page_title
      "Submission for | #{@submission.target.title}"
    end

    def markdown_prop(markdown)
      { markdown: markdown, profile: 'permissive' }.to_json
    end

    def render_markdown?(item)
      %w[longText shortText link].include?(item['kind'])
    end

    def files?(item)
      item['kind'] == 'files'
    end

    def audio?(item)
      item['kind'] == 'audio'
    end

    def audio_file(item)
      TimelineEventFile.find(item['result'])
    end

    def files(item)
      TimelineEventFile.where(id: item['result'])
    end
  end
end
