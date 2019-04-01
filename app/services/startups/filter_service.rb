module Startups
  class FilterService
    def initialize(form, startups)
      @form = form
      @startups = startups
    end

    def startups
      startups = @form.level_id.present? ? @startups.where(id: Level.find_by(id: @form.level_id).startups) : @startups
      @form.search.present? ? filter_by_search(startups) : startups
    end

    private

    def filter_by_search(startups)
      search_term = "%#{@form.search.downcase}%"

      startups.where(
        'name ILIKE ?',
        search_term,
        search_term
      )
    end
  end
end
