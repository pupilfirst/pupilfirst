# We're setting up an empty framework of Lita methods our code refers to, to make it possible to test Lita-specific code
# without requiring Lita's dependencies, or running its code.
module Lita
  def self.register_handler(_klass)
    # noop
  end

  class Room
    def self.find_by_id(_id)
      # noop
    end
  end

  module Handlers
    # Empty handlers. Call payload handler methods in the spec.
    class Handler
      def self.route(_matcher, _method, _options)
        # noop
      end

      def self.on(_event)
        # noop
      end
    end
  end
end
