# We're setting up an empty framework of Lita methods our code refers to, to make it possible to test Lita-specific code
# without requiring Lita's dependencies, or running its code.
module Lita
  def self.register_handler(_klass)
  end

  class Room
    def self.find_by_id(_id)
    end
  end

  module Handlers
    class Handler
      def self.on(_event)
        # Do nothing. Call payload handler methods in the spec.
      end
    end
  end
end
