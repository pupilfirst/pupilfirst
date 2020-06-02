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
    Founder.joins(:taggings).includes(:tags, startup: :tags).find_each do |student|
      team = student.startup
      student_tags = student.tags.pluck(:name)
      team_tags = team.tags.pluck(:name)

      # If this student has any tag that the team doesn't have, add it to the team.
      if (student_tags - team_tags).any?
        team.tag_list.add(*student_tags)
        team.save!
      end
    end

    # ############################## #
    # TODO: Remove all founder tags. #
    # ############################## #
  end

  def down
    # noop
  end
end
