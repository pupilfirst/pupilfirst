module Types
  class LevelUpEligibility < Types::BaseEnum
    value 'Eligible', 'This student is eligible to level up'
    value 'AtMaxLevel', 'This student is already at the max level'
    value 'NoMilestonesInLevel', "There are no milestone targets in the student's level"
    value 'CurrentLevelIncomplete', 'This student has not done the required work in the current level'
    value 'PreviousLevelIncomplete', 'This student has incomplete targets in a previous level'
    value 'TeamMembersPending', "This student's team-mates have not done the required work for leveling up"
    value 'DateLocked', 'The next level is yet to be unlocked'
  end
end
