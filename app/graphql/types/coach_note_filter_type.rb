module Types
  class CoachNoteFilterType < Types::BaseEnum
    value 'WithCoachNotes', 'To select students who have saved notes from coaches'
    value 'WithoutCoachNotes', 'To select students who do not have any notes from coaches'
    value 'IgnoreCoachNotes', 'To select students regardless of whether they have coach notes or not'
  end
end
