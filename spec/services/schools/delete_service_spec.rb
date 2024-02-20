require "rails_helper"

describe Schools::DeleteService do
  subject { described_class.new(school_1) }

  # School 1
  let(:school_1) { create :school, :current }
  let(:organisation_s1) { create :organisation, school: school_1 }
  let(:user_s1) do
    create :user, school: school_1, organisation: organisation_s1
  end
  let!(:organisation_admin_s1) do
    create :organisation_admin, user: user_s1, organisation: organisation_s1
  end
  let!(:school_string_s1) do
    create :school_string, :privacy_policy, school: school_1
  end
  let!(:school_link_s1) { create :school_link, :header, school: school_1 }
  let!(:school_admin_s1) do
    create :school_admin, school: school_1, user: user_s1
  end
  let!(:course_s1) { create :course, school: school_1 }
  let!(:community_s1) { create :community, school: school_1 }
  let!(:markdown_attachment_s1) do
    create :markdown_attachment, user: user_s1, school: school_1
  end
  let!(:domain_s1) { create :domain, school: school_1 }
  let!(:audit_record_s1) do
    create :audit_record, :add_school_admin, school: school_1
  end
  let!(:faculty_s1) { create :faculty, user: user_s1 }

  let!(:calendar) { create :calendar, course: course_s1 }
  let!(:calendar_event) { create :calendar_event, calendar: calendar }

  let!(:standing_s1) { create :standing, school: school_1, default: true }

  # School 2
  let(:school_2) { create :school }
  let(:organisation_s2) { create :organisation, school: school_2 }
  let(:user_s2) do
    create :user, school: school_2, organisation: organisation_s2
  end
  let!(:organisation_admin_s2) do
    create :organisation_admin, user: user_s2, organisation: organisation_s2
  end
  let!(:school_string_s2) do
    create :school_string, :privacy_policy, school: school_2
  end
  let!(:school_link_s2) { create :school_link, :header, school: school_2 }
  let!(:school_admin_s2) do
    create :school_admin, school: school_2, user: user_s2
  end
  let!(:course_s2) { create :course, school: school_2 }
  let!(:community_s2) { create :community, school: school_2 }
  let!(:markdown_attachment_s2) do
    create :markdown_attachment, user: user_s2, school: school_2
  end
  let!(:domain_s2) { create :domain, :primary, school: school_2 }
  let!(:audit_record_s2) do
    create :audit_record, :add_school_admin, school: school_2
  end
  let!(:faculty_s2) { create :faculty, user: user_s2 }

  let!(:calendar_s2) { create :calendar, course: course_s2 }
  let!(:calendar_event_s2) { create :calendar_event, calendar: calendar_s2 }

  let!(:standing_s2) { create :standing, school: school_2, default: true }

  before do
    # Tag the schools.
    school_1.student_tag_list.add("school 1 tag")
    school_1.save!
    school_2.student_tag_list.add("school 2 tag")
    school_2.save!
  end

  let(:expectations) do
    [
      [Proc.new { School.count }, 2, 1],
      [Proc.new { User.count }, 2, 1],
      [Proc.new { Organisation.count }, 2, 1],
      [Proc.new { OrganisationAdmin.count }, 2, 1],
      [Proc.new { SchoolString.count }, 2, 1],
      [Proc.new { SchoolLink.count }, 2, 1],
      [Proc.new { SchoolAdmin.count }, 2, 1],
      [Proc.new { Course.count }, 2, 1],
      [Proc.new { Community.count }, 2, 1],
      [Proc.new { MarkdownAttachment.count }, 2, 1],
      [Proc.new { Domain.count }, 3, 1],
      [Proc.new { AuditRecord.count }, 2, 1],
      [Proc.new { Calendar.count }, 2, 1],
      [Proc.new { CalendarEvent.count }, 2, 1],
      [Proc.new { Standing.count }, 2, 1]
    ]
  end

  describe "#execute" do
    it "deletes all data related to the course and the course itself" do
      expect { subject.execute }.to(
        change { expectations.map { |e| e[0].call } }.from(
          expectations.pluck(1)
        ).to(expectations.pluck(2))
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
      expect { calendar_s2.reload }.not_to raise_error
      expect { calendar_event_s2.reload }.not_to raise_error
      expect { standing_s2.reload }.not_to raise_error
    end
  end
end
