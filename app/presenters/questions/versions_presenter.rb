module Questions
  class VersionsPresenter < ApplicationPresenter
    def initialize(view_context, question)
      super(view_context)

      @question = question
    end

    def version_number_for_question
      versions_count + 1
    end

    def version_number(index)
      versions_count - index
    end

    def markdown_prop(version, index)
      {
        id: version_number(index).to_s,
        text: version.value
      }.to_json
    end

    def markdown_props_for_questions
      {
        id: version_number_for_question.to_s,
        text: @question.description
      }.to_json
    end

    def versions
      @versions ||= @question.text_versions
    end

    def editor_name_for_question
      if @question.editor.present?
        @question.editor.user_profiles.where(school: current_school).first.name
      else
        @question.creator.user_profiles.where(school: current_school).first.name
      end
    end

    def editor_name(version)
      version.user.user_profiles.where(school: current_school).first.name
    end

    private

    def versions_count
      @versions_count ||= versions.count
    end
  end
end
