module Questions
  class VersionsPresenter < ApplicationPresenter
    def initialize(view_context, question)
      super(view_context)

      @question = question
    end

    def versions
      @versions ||= @question.text_versions
    end

    def version_number_for_question
      versions_count + 1
    end

    def markdown_prop(version, index)
      markdown_props_to_json(version_number(index), version.value)
    end

    def markdown_props_for_questions
      markdown_props_to_json(version_number_for_question, @question.description)
    end

    def editor_name_for_question
      if @question.editor.present?
        name(@question.editor)
      else
        name(@question.creator)
      end
    end

    def name(user)
      user.user_profiles.where(school: current_school).first.name
    end

    def updated_at(object)
      object.updated_at.to_formatted_s(:long)
    end

    def version_number(index)
      versions_count - index
    end

    private

    def markdown_props_to_json(id, text)
      {
        id: id.to_s,
        text: text
      }.to_json
    end

    def versions_count
      @versions_count ||= versions.count
    end
  end
end
