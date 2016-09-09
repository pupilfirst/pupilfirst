class Select2Presenter
  # Searches for a university with a term. Always returns 'other' university in search results.
  def self.search_for_college(term)
    colleges = College.joins(:state)
    query_words = term.split

    query_words.each do |query|
      colleges = colleges.where(
        'colleges.name ILIKE ? OR states.name ILIKE ? OR also_known_as ILIKE ?', "%#{query}%", "%#{query}%", "%#{query}%"
      )
    end

    select2_results = colleges.select(:id, :state_id, :name).group_by(&:state_id).each_with_object([]) do |search_result, results|
      results << {
        text: State.find(search_result[0]).name,
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
