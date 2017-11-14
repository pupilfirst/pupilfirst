# TODO: This handler should probably be renamed to 'miscellaneous.rb' or so and re-used for similar random cases
module Lita
  module Handlers
    class Thanks < Handler
      route(/\Athanks\s*\!*\s*\z|\Athank you\s*\!*\s*\z/i, :respond_to_thanks, command: true)

      def respond_to_thanks(response)
        response.reply random_response_to_thanks
      end

      private

      def random_response_to_thanks
        ['You are welcome :simple_smile:', 'It was my pleasure! :blush:', 'Anytime :thumbsup:'].sample
      end
    end

    Lita.register_handler(Thanks)
  end
end
