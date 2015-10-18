module Lita
  module Handlers
    class Activity < Handler
      route(/\Ahello\z/, :greet, command: true

      def greet(response)
        response.reply("Hello there, I am the vocalist!")
      end
    end

    Lita.register_handler(Activity)
  end
end
