require "rails_helper"

describe EmailBounces::RecordService do
  describe ".call" do
    it "records a hard bounce, stripping surrounding whitespace" do
      expect do
        described_class.call(
          email: "  Student@Example.org  ",
          type: "HardBounce"
        )
      end.to change(BounceReport, :count).by(1)

      report = BounceReport.find_by!(email: "student@example.org")
      expect(report.bounce_type).to eq("HardBounce")
    end

    it "preserves the first event when a complaint follows a bounce" do
      described_class.call(email: "student@example.org", type: "HardBounce")

      expect do
        described_class.call(email: "STUDENT@example.org", type: "SpamComplaint")
      end.not_to change(BounceReport, :count)

      expect(BounceReport.find_by!(email: "student@example.org").bounce_type)
        .to eq("HardBounce")
    end

    it "records spam complaints for previously unseen addresses" do
      described_class.call(email: "student@example.org", type: "SpamComplaint")
      expect(BounceReport.find_by!(email: "student@example.org").bounce_type)
        .to eq("SpamComplaint")
    end

    it "ignores temporary failures and missing addresses" do
      expect do
        described_class.call(email: "student@example.org", type: "SoftBounce")
        described_class.call(email: "  ", type: "HardBounce")
        described_class.call(email: nil, type: "SpamComplaint")
      end.not_to change(BounceReport, :count)
    end
  end
end
