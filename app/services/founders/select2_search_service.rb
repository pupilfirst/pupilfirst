module Founders
  class Select2SearchService
    def self.search_for_founder(term)
      founders = Founder.all
      query_words = term.split

      query_words.each do |query|
        founders = founders.where(
          'founders.name ILIKE ?', "%#{query}%"
        )
      end

      # Limit the number of object allocations.
      selected_founders = founders.includes(:startup).limit(19)

      select2_results = selected_founders.each_with_object([]) do |search_result, results|
        results <<
          {
            id: search_result.id,
            text: "#{search_result.name} (#{search_result.startup.name})"
          }
      end
      select2_results
    end
  end
end
