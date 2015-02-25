FactoryGirl.define do
  factory :mentor_meeting do
    user { create :founder }
    mentor
    purpose { Faker::Lorem.words(5).join ' ' }
    duration { MentorMeeting.valid_durations.sample }
    suggested_meeting_at { 3.days.from_now }
    suggested_meeting_time Mentor::AVAILABILITY_TIME_MORNING
  end
end
