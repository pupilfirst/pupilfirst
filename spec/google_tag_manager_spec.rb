require 'rails_helper'

RSpec.describe GoogleTagManager do
  let(:school) { create :school }

  describe "#setup_data_layer" do
    specify "user missing" do
      gtm = GoogleTagManager.new(school, nil, tracker: 'TRACKER-CODE')

      expect(gtm.setup_data_layer).to eq(
        <<~HTML
          window.dataLayer || (window.dataLayer = []);
          window.dataLayer.push({"schoolId":#{school.id},"userId":"N/A","userEmail":null});
          window.addEventListener("load", function() {
            if (window.performance && window.performance.timeOrigin && window.performance.now) {
              window.dataLayer.push({"pageLoadTime": Math.round(performance.now())});
            }
          });
        HTML
      )
    end

    specify "user present" do
      user = create :user, email: 'user@example.com'

      gtm = GoogleTagManager.new(school, user, tracker: 'TRACKER-CODE')

      expect(gtm.setup_data_layer).to eq(
        <<~HTML
          window.dataLayer || (window.dataLayer = []);
          window.dataLayer.push({"schoolId":#{school.id},"userId":#{user.id},"userEmail":"user@example.com"});
          window.addEventListener("load", function() {
            if (window.performance && window.performance.timeOrigin && window.performance.now) {
              window.dataLayer.push({"pageLoadTime": Math.round(performance.now())});
            }
          });
        HTML
      )
    end

    specify do
      gtm = GoogleTagManager.new(school, nil, tracker: nil)

      expect(gtm.setup_data_layer).to be_nil
    end
  end

  describe "#setup_gtm_head" do
    specify do
      gtm = GoogleTagManager.new(school, nil, tracker: 'TRACKER-CODE')

      expect(gtm.setup_gtm_head).to include('TRACKER-CODE')
    end

    specify do
      gtm = GoogleTagManager.new(school, nil, tracker: nil)

      expect(gtm.setup_gtm_head).to be_nil
    end
  end

  describe "#setup_gtm_body" do
    specify do
      gtm = GoogleTagManager.new(school, nil, tracker: 'TRACKER-CODE')

      expect(gtm.setup_gtm_body).to include('TRACKER-CODE')
    end

    specify do
      gtm = GoogleTagManager.new(school, nil, tracker: nil)

      expect(gtm.setup_gtm_body).to be_nil
    end
  end

  it do
    allow(ENV).to receive(:[]).with('GTM_TRACKER').and_return('TRACKER-CODE')
    gtm = GoogleTagManager.new(school, nil)
    expect(gtm.setup_gtm_head).to include('TRACKER-CODE')
    expect(gtm.setup_gtm_body).to include('TRACKER-CODE')
  end

  it do
    gtm = GoogleTagManager.new(school, nil, tracker: 'TRACKER-CODE')
    expect { |b| gtm.with(&b) }.to yield_with_args(gtm)
  end

  it do
    gtm = GoogleTagManager.new(school, nil, tracker: nil)
    expect { |b| gtm.with(&b) }.not_to yield_control
  end
end
