require "rails_helper"

RSpec.describe "Maintenance Mode", type: :request do
  include ConfigHelper
  let!(:school) { create :school, :current }

  context "when maintenance mode is enabled" do
    around { |example| with_secret(maintenance_mode: true) { example.run } }

    it "returns maintenance page" do
      get root_path

      expect(response.status).to eq 200
      expect(response.body).to include("We'll be back soon!")
      expect(response.body).to include("Sorry for the inconvenience")
    end
  end

  context "when maintenance mode is disabled" do
    around { |example| with_secret(maintenance_mode: false) { example.run } }

    it "returns normal page" do
      get root_path

      expect(response.status).to eq 200
      expect(response.body).not_to include("We'll be back soon!")
      expect(response.body).not_to include("Sorry for the inconvenience.")
      expect(response.body).to include(school.name)
    end
  end
end
