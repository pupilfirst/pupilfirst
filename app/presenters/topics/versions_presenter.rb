module Topics
  class VersionsPresenter < ApplicationPresenter
    def initialize(view_context, topic)
      super(view_context)

      @topic = topic
    end

    def page_title
      "Versions | #{@topic.title}"
    end

    def versions
      @versions ||= @topic.first_post.text_versions
    end

    def version_number_for_topic
      versions_count + 1
    end

    def markdown_prop(markdown)
      {
        markdown: markdown,
        profile: "questionAndAnswer"
      }.to_json
    end

    def editor_name_for_topic
      if @topic.first_post.editor.present?
        @topic.first_post.editor.name
      else
        @topic.creator.name
      end
    end

    def topic_updated_at
      @topic.updated_at.to_formatted_s(:long)
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
