module TimelineEvents
  class BuilderForm < Reform::Form
    # Add some slack to the max limit to allow for different length calculation at the front-end.
    MAX_DESCRIPTION_CHARACTERS = (TimelineEvent::MAX_DESCRIPTION_CHARACTERS * 1.1).to_i

    attr_accessor :founder

    property :target_id
    property :description, validates: { presence: true, length: { maximum: MAX_DESCRIPTION_CHARACTERS } }
    property :event_on, validates: { presence: true }
    property :links
    property :files, virtual: true
    property :files_metadata, virtual: true
    property :image
    property :share_on_facebook

    validate :files_should_have_metadata
    validate :target_status_submittable
    validate :links_should_have_correct_shape

    def links_should_have_correct_shape
      return if parsed_links.blank?

      invalid_link = parsed_links.find do |link|
        link[:title].blank? || link[:url].blank? || !link[:url].starts_with?('http')
      end

      errors[:links] << 'contains invalid links' if invalid_link.present?
    end

    def files_should_have_metadata
      return if files.blank?

      missing_metadata = files.keys.any? do |identifier|
        parsed_files_metadata[identifier].blank?
      end

      errors[:files_metadata] << 'is incomplete' if missing_metadata
    end

    def target
      @target ||= Target.find_by(id: target_id)
    end

    def parsed_files_metadata
      @parsed_files_metadata ||= JSON.parse(files_metadata)
    end

    def parsed_links
      # Symbolize the keys in each hash to maintain compatibility with old code.
      JSON.parse(links).map(&:symbolize_keys)
    end

    def target_status_submittable
      return if target.blank?

      if target.status(founder).in?([Target::UNSUBMITTABLE_STATUSES])
        errors[:target_id] << 'is not submittable'
      end
    end

    def save
      TimelineEvent.transaction do
        timeline_event = TimelineEvent.create!(
          target: target,
          founder: founder,
          startup: founder.startup,
          description: description,
          event_on: Time.zone.parse(event_on),
          links: parsed_links,
          image: image,
          share_on_facebook: share_on_facebook
        )

        create_files(timeline_event)

        TimelineEvents::AfterFounderSubmitJob.perform_later(timeline_event)
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
