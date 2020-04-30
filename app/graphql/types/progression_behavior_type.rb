module Types
  class ProgressionBehaviorType < Types::BaseEnum
    value Course::PROGRESSION_BEHAVIOR_LIMITED, 'Allow students to level up a limited number of times'
    value Course::PROGRESSION_BEHAVIOR_UNLIMITED, 'Allow students to level up without getting submissions reviewed'
    value Course::PROGRESSION_BEHAVIOR_STRICT, 'Allow students to level up only after getting submissions reviewed'
  end
end
