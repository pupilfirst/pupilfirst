module Answers
  class VersionsPresenter < ApplicationPresenter
    def initialize(view_context, answer)
      super(view_context)

      @answer = answer
    end

    def versions
      @versions ||= @answer.text_versions
    end

    def version_number_for_answer
      versions_count + 1
    end

    def markdown_prop(markdown)
      {
        markdown: markdown
      }.to_json
    end

    def version_number(index)
      versions_count - index
    end

    def editor_name_for_answer
      if @answer.editor.present?
        name(@answer.editor)
        @answer.editor.user_profiles.where(school: current_school).first.name
      else
        name(@answer.creator)
      end
    end

    def name(user)
      user.user_profiles.where(school: current_school).first.name
    end

    def updated_at(object)
      object.updated_at.to_formatted_s(:long)
    end

    private

    def versions_count
      @versions_count ||= versions.count
    end
  end
end
