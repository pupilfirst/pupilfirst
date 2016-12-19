module TimelineEventTypes
  # This returns a hash of the form { role: { id: { title: '', sample: ''}, ...}, ... } of all timeline event types,
  # starting with suggested types for the supplied startup.
  #
  # TODO: Spec TimelineEventTypes::ListService
  class ListService
    def initialize(startup)
      @startup = startup
      @list = {}
    end

    def list
      add_suggested
      add_remaining

      @list
    end

    private

    def suggested
      @suggested ||= TimelineEventType.suggested_for(@startup)
    end

    def add_suggested
      if suggested.present?
        @list['Suggested'] = suggested.order(:title).each_with_object({}) do |suggested_type, list|
          list[suggested_type.id] = { title: suggested_type.title, sample: suggested_type.sample }
        end
      end
    end

    def add_remaining
      TimelineEventType.distinct(:role).pluck(:role).each do |role|
        @list[role] = TimelineEventType.where(role: role).where.not(id: suggested.pluck(:id)).order(:title).each_with_object({}) do |remaining_type, list|
          list[remaining_type.id] = { title: remaining_type.title, sample: remaining_type.sample }
        end
      end
    end
  end
end
