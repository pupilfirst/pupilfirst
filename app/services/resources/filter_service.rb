module Resources
  class FilterService
    def initialize(form, resources)
      @form = form
      @resources = resources
    end

    def resources
      resources = @form.tags.any?(&:present?) ? @resources.tagged_with(@form.tags) : @resources
      resources = filter_by_search(resources) if @form.search.present?
      resources = filter_by_date(resources) if @form.created_after.present?
      paginate(resources)
    end

    private

    def filter_by_search(resources)
      resources.title_matches(@form.search)
    end

    def filter_by_date(resources)
      resources.where('resources.created_at > ?', date_filter_values[@form.created_after.to_sym])
    end

    def paginate(resources)
      page = @form.page.present? ? @form.page : nil
      resources.paginate(page: page, per_page: 9)
    end

    def date_filter_values
      {
        'Since Yesterday': 1.day.ago.beginning_of_day,
        'Past Week': 1.week.ago,
        'Past Month': 1.month.ago,
        'Past Year': 1.year.ago
      }
    end
  end
end
