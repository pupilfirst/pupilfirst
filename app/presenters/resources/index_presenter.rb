module Resources
  class IndexPresenter < ApplicationPresenter
    def library_subheading
      @library_subheading ||= SchoolString::LibraryIndexSubheading.for(view.current_school)
    end

    def results_caption
      view.t('resources.index.results_caption', tag_text: tag_text, search_text: search_text)
    end

    def zero_results_text
      login_text = view.current_founder.blank? ? " or #{view.link_to('logging in', view.new_user_session_path, rel: 'nofollow')} to unlock private resources" : ''

      view.t('resources.index.zero_results', tag_text: tag_text, search_text: search_text, login_text: login_text)
    end

    private

    def tag_text
      @tag_text ||= begin
        tags = (view.params.dig(:resources_filter, :tags) || []) - ['']
        tags.present? ? "tagged with '#{tags.join(', ')}'" : ''
      end
    end

    def search_text
      @search_text ||= begin
        search_term = view.params.dig(:resources_filter, :search)&.downcase
        search_term.present? ? "whose title contains '#{search_term}'" : ''
      end
    end
  end
end
