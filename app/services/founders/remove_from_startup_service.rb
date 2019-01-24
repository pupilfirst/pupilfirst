module Founders
  class RemoveFromStartupService
    NoOtherFoundersInStartupException = Class.new(StandardError)

    def initialize(founder)
      @founder = founder
    end

    def execute
      raise NoOtherFoundersInStartupException if startup.founders.count == 1

      @founder.update!(exited: true)
    end

    private

    def startup
      @startup ||= @founder.startup
    end
  end
end
