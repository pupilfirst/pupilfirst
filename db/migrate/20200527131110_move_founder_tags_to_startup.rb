class MoveFounderTagsToStartup < ActiveRecord::Migration[6.0]
  class Startup < ApplicationRecord
    acts_as_taggable

    def self.name
      'Startup'
    end
  end

  class Founder < ApplicationRecord
    acts_as_taggable

    belongs_to :startup

    def self.name
      'Founder'
    end
  end

  def up
    require_relative '../../lib/command_line_progress'

    clp = CommandLineProgress.new(Founder.joins(:taggings).distinct.count)

    Founder.joins(:taggings).includes(:tags, startup: :tags).distinct.find_each do |student|
      clp.tick

      team = student.startup
      student_tags = student.tags.pluck(:name)
      team_tags = team.tags.pluck(:name)

      # If this student has any tag that the team doesn't have, add it to the team.
      if (student_tags - team_tags).any?
        team.tag_list.add(*student_tags)
        team.save!
      end
    end

    old_tags = ActsAsTaggableOn::Tagging.where(taggable_type: 'Founder')
    puts "Deleting #{old_tags.count} old student tags..."
    old_tags.delete_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
