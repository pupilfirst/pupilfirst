module Startups
  class Select2SearchService
    def self.search_for_startup(term)
      startups = Startup.all
      query_words = term.split

      query_words.each do |query|
        startups = startups.where(
          'startups.name ILIKE ?', "%#{query}%"
        )
      end

      # Limit the number of object allocations.
      selected_startups = startups.limit(19)

      select2_results = selected_startups.select(:id, :name).each_with_object([]) do |search_result, results|
        results <<
          {
            id: search_result.id,
            text: search_result.name
          }
      end
      select2_results
    end
  end
end
