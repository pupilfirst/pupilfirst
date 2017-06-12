module EngineeringMetrics
  class TrelloStatsService
    # get data from any Trello API end-point.
    def get(path)
      key = Rails.application.secrets.trello[:app_key]
      token = Rails.application.secrets.trello[:api_token]
      url = 'https://api.trello.com/1/' + path + "?key=#{key}&token=#{token}"
      JSON.parse(RestClient.get(url))
    end

    # count of open cards in the Rollbar list
    def rollbar_cards_count
      list_id = Rails.application.secrets.trello[:rollbar_list_id]
      open_cards = get("lists/#{list_id}/cards/open")
      open_cards.count
    end

    # count of cards labelled as Bug
    def bug_labelled_cards_count
      cards = get("boards/#{Rails.application.secrets.trello[:engineering_board_id]}/cards")
      cards.select { |card| card['idLabels'].include? Rails.application.secrets.trello[:bug_label_id] }
    end
  end
end
