FactoryGirl.define do
  factory :mentor_meeting do
    user { create :user_with_out_password }
    mentor
    purpose { Faker::Lorem.words(5).join ' ' }
    duration { MentorMeeting.valid_durations.sample }
    suggested_meeting_at { 3.days.from_now }
    suggested_meeting_time Mentor::AVAILABILITY_TIME_MORNING

    after :build do |meeting|
      startup = create :startup
      startup.founders << meeting.user
    end
  end
end
