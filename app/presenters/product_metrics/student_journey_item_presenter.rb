module ProductMetrics
  class StudentJourneyItemPresenter < ApplicationPresenter
    def initialize(view_context, journey_point)
      @journey_point = journey_point
      super(view_context)
    end

    def key
      return ProductMetrics::IndexPresenter::MEMBER_JOURNEY[@journey_point] if ProductMetrics::IndexPresenter::MEMBER_JOURNEY.key?(@journey_point)
      raise "Cannot resolve icon for journey point '#{@journey_point}'"
    end
  end
end
