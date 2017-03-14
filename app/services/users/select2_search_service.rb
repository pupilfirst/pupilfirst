module Users
  class Select2SearchService
    def self.search_for_user(term)
      users = User.all
      query_words = term.split

      query_words.each do |query|
        users = users.where(
          'users.email ILIKE ?', "%#{query}%"
        )
      end

      # Limit the number of object allocations.
      selected_users = users.limit(19)

      select2_results = selected_users.select(:id, :email).each_with_object([]) do |search_result, results|
        results <<
          {
            id: search_result.id,
            text: search_result.email
          }
      end
      select2_results
    end
  end
end
