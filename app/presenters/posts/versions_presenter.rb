module Posts
  class VersionsPresenter < ApplicationPresenter
    def initialize(view_context, post)
      super(view_context)

      @post = post
    end

    def page_title
      I18n.t('presenters.posts.versions.page_title.title')
    end

    def versions
      @versions ||= @post.text_versions
    end

    def version_number_for_post
      versions_count + 1
    end

    def markdown_prop(markdown)
      { markdown: markdown, profile: 'permissive' }.to_json
    end

    def version_number(index)
      versions_count - index
    end

    def editor_name_for_answer
      @post.editor&.name || 'Unknown'
    end

    def updated_at(object)
      object.updated_at.to_fs(:long)
    end

    def versions_count
      @versions_count ||= versions.count
    end
  end
end
