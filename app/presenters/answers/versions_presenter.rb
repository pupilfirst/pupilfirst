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
      {
        id: version_number(index).to_s,
        text: version.value
      }.to_json
    end

    def markdown_props_for_answer
      {
        id: version_number_for_answer.to_s,
        text: @answer.description
      }.to_json
    end

    def editor_name_for_answer
      if @answer.editor.present?
        @answer.editor.user_profiles.where(school: current_school).first.name
      else
        @answer.creator.user_profiles.where(school: current_school).first.name
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
