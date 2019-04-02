module Resources
  class IndexPresenter < ApplicationPresenter
    def initialize(view_context, form, resources)
      @form = form
      @resources = resources

      super(view_context)
    end

    def resource_tags
      @resource_tags ||= Resource.tag_counts_on(:tags).pluck(:name)
    end

    # rubocop:disable Metrics/PerceivedComplexity
    def notice
      @notice ||= begin
        if @form.tags.present? || @form.search.present? || @form.created_after.present?
          if @resources.blank?
            view.t('resources.index.filter_zero_results')
          else
            view.t('resources.index.filter_notice')
          end
        elsif @resources.blank?
          view.t('resources.index.zero_results')
        end
      end
    end
    # rubocop:enable Metrics/PerceivedComplexity

    def notice?
      notice.present?
    end

    def library_subheading
      @library_subheading ||= SchoolString::LibraryIndexSubheading.for(current_school)
    end
  end
end
