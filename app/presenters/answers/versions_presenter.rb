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

    def version_number(index)
      versions_count - index
    end

    def markdown_prop(version, index)
      markdown_props_to_json(version_number(index), version.value)
    end

    def markdown_props_for_answer
      markdown_props_to_json(version_number_for_answer, @answer.description)
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

    def markdown_props_to_json(id, text)
      {
        id: id.to_s,
        text: text
      }.to_json
    end
  end
end
