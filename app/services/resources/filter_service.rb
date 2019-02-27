module Resources
  class FilterService
    def initialize(form, resources)
      @form = form
      @resources = resources
    end

    def resources
      resources = @form.tags.present? ? @resources.tagged_with(@form.tags) : @resources
      resources = filter_by_search_term(resources) if @form.search.present?
      @form.created_after.present? ? filter_by_date(resources) : resources
    end

    private

    def filter_by_search_term(resources)
      resources.where("lower(resources.title) LIKE ?", "%#{@form.search.downcase}%")
    end

    def filter_by_date(resources)
      resources.where('resources.created_at > ?', date_filter_values[@form.created_after.to_sym])
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
