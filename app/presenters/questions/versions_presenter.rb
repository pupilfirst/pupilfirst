module Questions
  class VersionsPresenter < ApplicationPresenter
    def initialize(view_context, question)
      super(view_context)

      @question = question
    end

    def page_title
      "Versions | #{@question.title}"
    end

    def versions
      @versions ||= @question.text_versions
    end

    def version_number_for_question
      versions_count + 1
    end

    def markdown_prop(markdown)
      {
        markdown: markdown,
        profile: "questionAndAnswer"
      }.to_json
    end

    def editor_name_for_question
      if @question.editor.present?
        @question.editor.name
      else
        @question.creator.name
      end
    end

    def question_updated_at
      @question.updated_at.to_formatted_s(:long)
    end

    def edited_at(version)
      version.edited_at.to_formatted_s(:long)
    end

    def version_number(index)
      versions_count - index
    end

    private

    def versions_count
      @versions_count ||= versions.count
    end
  end
end
