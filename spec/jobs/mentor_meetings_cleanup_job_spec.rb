require 'spec_helper'

RSpec.describe MentorMeetingsCleanupJob, :type => :job do

  before(:each) do
    Delayed::Worker.delay_jobs = false
    @meeting = FactoryGirl.create(:mentor_meeting)
    @id = @meeting.id
  end

  describe "expire" do
  	it "expires a meeting whose request timed out" do
 		@meeting.update_attributes(status: MentorMeeting::STATUS_REQUESTED, suggested_meeting_at: 1.minute.ago)
 		MentorMeetingsCleanupJob.perform_later
    @meeting = MentorMeeting.find(@id)
 		expect(@meeting.status).to eq(MentorMeeting::STATUS_EXPIRED)
 	  end
  end
end
