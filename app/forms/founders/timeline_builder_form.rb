module Founders
  class TimelineBuilderForm < Reform::Form
    # Add some slack to the max limit to allow for different length calculation at the front-end.
    MAX_DESCRIPTION_CHARACTERS = (TimelineEvent::MAX_DESCRIPTION_CHARACTERS * 1.1).to_i

    property :target_id
    property :description, validates: { presence: true, length: { maximum: MAX_DESCRIPTION_CHARACTERS } }
    property :timeline_event_type_id, validates: { presence: true }
    property :event_on, validates: { presence: true }
    property :links
    property :files, virtual: true
    property :files_metadata, virtual: true
    property :image
    property :share_on_facebook

    validate :timeline_event_type_should_exist
    validate :files_should_have_metadata

    def timeline_event_type_should_exist
      return if timeline_event_type.present?
      errors[:timeline_event_type_id] << 'is invalid'
    end

    def files_should_have_metadata
      return if files.blank?

      missing_metadata = files.keys.any? do |identifier|
        parsed_files_metadata[identifier].blank?
      end

      errors[:files_metadata] << 'is incomplete' if missing_metadata
    end

    def timeline_event_type
      @timeline_event_type ||= TimelineEventType.find_by(id: timeline_event_type_id)
    end

    def target
      @target ||= Target.find_by(id: target_id)
    end

    def parsed_files_metadata
      @parsed_metadata ||= JSON.parse(files_metadata)
    end

    def parsed_links
      # Symbolize the keys in each hash to maintain compatibility with old code.
      JSON.parse(links).map(&:symbolize_keys)
    end

    def save(founder)
      TimelineEvent.transaction do
        timeline_event = TimelineEvent.create!(
          target: target,
          founder: founder,
          startup: founder.startup,
          description: description,
          timeline_event_type: timeline_event_type,
          event_on: Time.zone.parse(event_on),
          links: parsed_links,
          image: image,
          share_on_facebook: share_on_facebook,
          iteration: founder.startup.iteration
        )

        create_files(timeline_event)

        TimelineEvents::AfterFounderSubmitJob.perform_later(timeline_event)

        add_intercom_tag(founder)
      end
    end

    # Add task submission tags on Intercom if applicable
    def add_intercom_tag(founder)
      if target&.key == Target::KEY_ADMISSIONS_CODING_TASK
        Intercom::FounderTaggingJob.perform_later(founder, 'Coding Task Submitted')
      elsif target&.key == Target::KEY_ADMISSIONS_VIDEO_TASK
        Intercom::FounderTaggingJob.perform_later(founder, 'Video Task Submitted')
      end
    end

    # Save timeline event files with metadata.
    def create_files(timeline_event)
      return if files.blank?

      files.each do |identifier, file|
        metadata = parsed_files_metadata[identifier]

        timeline_event.timeline_event_files.create!(
          file: file,
          title: metadata['title'],
          private: metadata['private']
        )
      end
    end
  end
end
