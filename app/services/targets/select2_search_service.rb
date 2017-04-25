module Targets
  class Select2SearchService
    def self.search_for_target(term)
      targets = Target.all
      query_words = term.split

      query_words.each do |query|
        targets = targets.where(
          'targets.title ILIKE ?', "%#{query}%"
        )
      end

      # Limit the number of object allocations.
      selected_targets = targets.limit(19)

      select2_results = selected_targets.select(:id, :title).each_with_object([]) do |search_result, results|
        results <<
          {
            id: search_result.id,
            text: search_result.title
          }
      end
      select2_results
    end
  end
end
