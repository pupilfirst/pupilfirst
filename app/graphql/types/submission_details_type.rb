module Types
  class SubmissionDetailsType < Types::BaseObject
    field :submissions, [Types::Submission], null: false
    field :target_id, ID, null: false
    field :target_title, String, null: false
    field :user_names, String, null: false
    field :level_number, String, null: false
  end
end
