require 'rails_helper'

describe DailyDigestService do
  include ActiveSupport::Testing::TimeHelpers
  include HtmlSanitizerSpecHelper

  subject { described_class.new }

  around(:each) do |example|
    # Time travel to the test time when running a spec.
    travel_to(Time.zone.parse('2019-07-16T18:00:00+05:30')) do
      example.run
    end
  end

  let(:school) { create :school, :current }

  let!(:domain) { create :domain, :primary, school: school }

  let(:team_1) { create :startup }
  let(:team_2) { create :startup }
  let(:team_3) { create :startup }

  let(:community_1) { create :community, school: school, courses: [team_1.course] }
  let(:community_2) { create :community, school: school, courses: [team_1.course, team_2.course] }
  let(:community_3) { create :community, school: school, courses: [team_1.course, team_2.course, team_3.course] }

  let(:t1_user) { team_1.founders.first.user }
  let(:t2_user_1) { team_2.founders.first.user }
  let(:t2_user_2) { team_2.founders.last.user }
  let(:t3_user) { team_3.founders.first.user }

  let!(:question_c1) { create :question, community: community_1, creator: t1_user }
  let!(:question_c2_1) { create :question, community: community_2, creator: t2_user_1 }
  let!(:question_c2_2) { create :question, community: community_2, creator: t2_user_2 }
  let!(:question_c3_1) { create :question, community: community_3, creator: t3_user, created_at: 2.days.ago }
  let!(:question_c3_2) { create :question, community: community_3, creator: t3_user, created_at: 8.days.ago }

  before do
    # Activate daily digest emails for three of the four users.
    [t1_user, t2_user_1, t3_user].each do |user|
      user.update!(preferences: { daily_digest: true })
    end
  end

  describe '#execute' do
    it 'sends digest emails containing details about new and unanswered questions' do
      subject.execute

      open_email(t1_user.email)

      s1 = current_email.subject
      expect(s1).to include(school.name)
      expect(s1).to include('Daily Digest')
      expect(s1).to include('Jul 16, 2019')

      b1 = sanitize_html(current_email.body)

      # The email should link to all three communities.
      expect(b1).to include(community_1.name)
      expect(b1).to include(community_2.name)
      expect(b1).to include(community_3.name)

      # It should include all questions except the one from 8 days ago.
      expect(b1).to include(question_c1.title)
      expect(b1).to include(question_c2_1.title)
      expect(b1).to include(question_c2_2.title)
      expect(b1).to include(question_c3_1.title)
      expect(b1).not_to include(question_c3_2.title)

      open_email(t2_user_1.email)

      s2 = current_email.subject

      # Subject should be identical to first.
      expect(s2).to eq(s1)

      b2 = sanitize_html(current_email.body)

      # It should not have questions from the first community and one from 8 days ago.
      expect(b2).not_to include(question_c1.title)
      expect(b2).to include(question_c2_1.title)
      expect(b2).to include(question_c2_2.title)
      expect(b2).to include(question_c3_1.title)
      expect(b2).not_to include(question_c3_2.title)

      # Second user in second course shouldn't receive any email because daily digest hasn't been turned on.
      open_email(t2_user_2.email)
      expect(current_email).to eq(nil)

      open_email(t3_user.email)

      s3 = current_email.subject

      # Subject should be identical to first.
      expect(s3).to eq(s1)

      b3 = sanitize_html(current_email.body)

      # It should only have the one question from third community.
      expect(b3).not_to include(question_c1.title)
      expect(b3).not_to include(question_c2_1.title)
      expect(b3).not_to include(question_c2_2.title)
      expect(b3).to include(question_c3_1.title)
      expect(b3).not_to include(question_c3_2.title)
    end

    context 'when there are more than 5 unanswered questions in the past seven days' do
      let!(:question_c3_3) { create :question, community: community_3, creator: t3_user, created_at: 2.days.ago }
      let!(:question_c3_4) { create :question, community: community_3, creator: t3_user, created_at: 3.days.ago }
      let!(:question_c3_5) { create :question, community: community_3, creator: t3_user, created_at: 4.days.ago }
      let!(:question_c3_6) { create :question, community: community_3, creator: t3_user, created_at: 5.days.ago }
      let!(:question_c3_7) { create :question, community: community_3, creator: t3_user, created_at: 6.days.ago }

      it 'only mails up to 5 unanswered questions' do
        subject.execute

        open_email(t3_user.email)

        b = sanitize_html(current_email.body)

        expect(b).not_to include(question_c1.title)
        expect(b).not_to include(question_c2_1.title)
        expect(b).not_to include(question_c2_2.title)
        expect(b).to include(question_c3_1.title)
        expect(b).not_to include(question_c3_2.title)
        expect(b).to include(question_c3_3.title)
        expect(b).to include(question_c3_4.title)
        expect(b).to include(question_c3_5.title)
        expect(b).to include(question_c3_6.title)
        expect(b).not_to include(question_c3_7.title)
      end
    end
  end
end
