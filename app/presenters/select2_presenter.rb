class Select2Presenter
  # Searches for a college with a term. Always returns 'other' college in search results.
  def self.search_for_college(term)
    colleges = College.joins(:state)
    query_words = term.split

    query_words.each do |query|
      colleges = colleges.where(
        'colleges.name ILIKE ? OR states.name ILIKE ? OR also_known_as ILIKE ?', "%#{query}%", "%#{query}%", "%#{query}%"
      )
    end

    # Limit the number of object allocations.
    selected_colleges = colleges.count > 19 ? colleges.limit(19) : colleges

    select2_results = selected_colleges.select(:id, :state_id, :name, 'states.name AS state_name').group_by(&:state_id).each_with_object([]) do |search_result, results|
      results << {
        text: search_result[1].first.state_name,
        children: search_result[1].map do |college|
          {
            id: college.id,
            text: college.name
          }
        end
      }
    end

    select2_results + [{ text: 'Other', children: [{ id: 'other', text: "My college isn't listed" }] }]
  end
end
