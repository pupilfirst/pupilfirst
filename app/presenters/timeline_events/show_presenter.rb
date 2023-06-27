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
      { markdown: markdown, profile: "permissive" }.to_json
    end

    def render_markdown?(item)
      %w[longText shortText].include?(item["kind"])
    end

    def files?(item)
      item["kind"] == "files"
    end

    def audio?(item)
      item["kind"] == "audio"
    end

    def link?(item)
      item["kind"] == "link"
    end

    def audio_file(item)
      TimelineEventFile.find(item["result"])
    end

    def files(item)
      TimelineEventFile.where(id: item["result"])
    end

    def submission_from
      if @submission.founder.team.present? && @submission.team_submission?
        @submission.founder.team.name
      else
        @submission.founder.name
      end
    end

    def icon_class_for(item)
      case item["kind"]
      when "longText", "shortText"
        "if i-long-text-light if-fw"
      when "link"
        "if i-link-light if-fw"
      when "files"
        "if i-file-light if-fw"
      when "audio"
        "if i-file-music-light if-fw"
      else
        "if i-check-circle-alt-regular if-fw"
      end
    end
  end
end
