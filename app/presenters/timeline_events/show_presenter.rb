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
      {
        markdown: markdown,
        profile: "questionAndAnswer"
      }.to_json
    end
  end
end
