require 'rails_helper'

describe Schools::DeleteService do
  subject { described_class.new(school_1) }

  let(:school_1) { create :school, :current }
  let(:user_s1) { create :user, school: school_1 }
  let!(:school_string_s1) { create :school_string, :privacy_policy, school: school_1 }
  let!(:school_link_s1) { create :school_link, :header, school: school_1 }
  let!(:school_admin_s1) { create :school_admin, school: school_1, user: user_s1 }
  let!(:course_s1) { create :course, school: school_1 }
  let!(:community_s1) { create :community, school: school_1 }
  let!(:markdown_attachment_s1) { create :markdown_attachment, user: user_s1, school: school_1 }
  let!(:domain_s1) { create :domain, school: school_1 }
  let!(:audit_record_s1) { create :audit_record, :add_school_admin, school: school_1 }
  let!(:faculty_s1) { create :faculty, user: user_s1 }

  let(:school_2) { create :school }
  let(:user_s2) { create :user, school: school_2 }
  let!(:school_string_s2) { create :school_string, :privacy_policy, school: school_2 }
  let!(:school_link_s2) { create :school_link, :header, school: school_2 }
  let!(:school_admin_s2) { create :school_admin, school: school_2, user: user_s2 }
  let!(:course_s2) { create :course, school: school_2 }
  let!(:community_s2) { create :community, school: school_2 }
  let!(:markdown_attachment_s2) { create :markdown_attachment, user: user_s2, school: school_2 }
  let!(:domain_s2) { create :domain, :primary, school: school_2 }
  let!(:audit_record_s2) { create :audit_record, :add_school_admin, school: school_2 }
  let!(:faculty_s2) { create :faculty, user: user_s2 }

  before do
    # Tag the schools.
    school_1.founder_tag_list.add('school 1 tag')
    school_1.save!
    school_2.founder_tag_list.add('school 2 tag')
    school_2.save!
  end

  let(:expectations) {
    [
      [Proc.new { School.count }, 2, 1],
      [Proc.new { User.count }, 2, 1],
      [Proc.new { SchoolString.count }, 2, 1],
      [Proc.new { SchoolLink.count }, 2, 1],
      [Proc.new { SchoolAdmin.count }, 2, 1],
      [Proc.new { Course.count }, 2, 1],
      [Proc.new { Community.count }, 2, 1],
      [Proc.new { MarkdownAttachment.count }, 2, 1],
      [Proc.new { Domain.count }, 3, 1],
      [Proc.new { AuditRecord.count }, 2, 1],
    ]
  }

  describe '#execute' do
    it 'deletes all data related to the course and the course itself' do
      expect { subject.execute }.to(
        change {
          expectations.map { |e| e[0].call }
        }.from(
          expectations.map { |e| e[1] }
        ).to(
          expectations.map { |e| e[2] }
        )
      )

      expect { school_2.reload }.not_to raise_error
      expect { user_s2.reload }.not_to raise_error
      expect { school_string_s2.reload }.not_to raise_error
      expect { school_link_s2.reload }.not_to raise_error
      expect { school_admin_s2.reload }.not_to raise_error
      expect { course_s2.reload }.not_to raise_error
      expect { community_s2.reload }.not_to raise_error
      expect { markdown_attachment_s2.reload }.not_to raise_error
      expect { domain_s2.reload }.not_to raise_error
      expect { audit_record_s2.reload }.not_to raise_error
      expect { faculty_s2.reload }.not_to raise_error
    end
  end
end
