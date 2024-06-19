# spec/services/beckn/api/on_search_data_service.rb
require "rails_helper"

RSpec.describe Beckn::Api::OnSearchDataService do
  describe "#execute" do
    let(:payload) { { message: {} } }

    let!(:service) { described_class.new(payload) }
    let!(:school_1) { create(:school, :beckn_enabled) }
    let!(:course_1_s1) do
      create(:course, school: school_1, beckn_enabled: true)
    end
    let!(:course_2_s1) do
      create(:course, school: school_1, beckn_enabled: true)
    end
    let!(:course_3_s1) do
      create(:course, school: school_1, beckn_enabled: false)
    end

    let!(:school_2) { create(:school, :beckn_enabled) }
    let!(:course_1_s2) do
      create(:course, school: school_2, beckn_enabled: true)
    end
    let!(:course_2_s2) do
      create(:course, school: school_2, beckn_enabled: false)
    end

    let!(:school_not_in_beckn) { create(:school, beckn_enabled: false) }
    let!(:course_1_s3) do
      create(:course, school: school_not_in_beckn, beckn_enabled: true)
    end

    let(:schools) { School.beckn_enabled }

    before do
      School.all.each do |school|
        create(:course_category, school: school)
        create(:course_category, school: school)

        school.courses.each do |course|
          course.course_categories << school.course_categories.sample
        end
      end
    end

    it "returns expected catalog details" do
      result = service.execute

      # Check the descriptor
      expect(result[:message][:catalog][:descriptor]).to eq(
        { name: "Course Catalog" },
      )

      # Check each school
      schools.each_with_index do |school, index|
        school_result = result[:message][:catalog][:providers][index]

        # Check the school's id and descriptor
        expect(school_result[:id]).to eq(school.id.to_s)
        expect(school_result[:descriptor]).to include(
          name: school.name,
          short_desc: SchoolString::Description.for(school) || school.name,
          long_desc: school.about.presence || "",
        )

        expect(school_result[:categories]).to eq(
          school.course_categories.map do |category|
            {
              id: category.id.to_s,
              descriptor: {
                code: category.id.to_s,
                name: category.name,
              },
            }
          end,
        )

        # Check each course
        school.courses.beckn_enabled.each_with_index do |course, course_index|
          course_result = school_result[:items][course_index]

          # Check the course's id, quantity, and descriptor
          expect(course_result[:id]).to eq(course.id.to_s)
          expect(course_result[:quantity]).to eq({ maximum: { count: 1 } })
          expect(course_result[:descriptor]).to include(
            name: course.name,
            short_desc: course.description.presence || "",
            long_desc: course.about.presence || "",
            additional_desc: {
              url:
                "https://#{school.domains.primary.fqdn}/courses/#{course.id}",
              content_type: "text/html",
            },
          )

          expect(course_result[:category_ids]).to eq(
            course.course_categories.map { |x| x.id.to_s },
          )

          # Check the course's creator, price, rating, and rateable
          expect(course_result[:creator]).to eq(
            {
              descriptor: {
                name: school.name,
                short_desc:
                  SchoolString::Description.for(school) || school.name,
                long_desc: school.about.presence || "",
                images: [],
              },
            },
          )
          expect(course_result[:price]).to eq({ currency: "INR", value: "0" })
          expect(course_result[:rating]).to eq(course.rating.to_s)
          expect(course_result[:rateable]).to be true

          # Check each tag
          course.highlights.each_with_index do |tag, tag_index|
            tag_result = course_result[:tags][0][:list][tag_index]

            expect(tag_result[:descriptor]).to eq(
              { code: tag["title"].downcase.tr(" ", "-"), name: tag["title"] },
            )
            expect(tag_result[:value]).to eq(tag["description"].to_s)
          end
        end
      end
    end

    it "does not return non-beckn enabled schools and courses" do
      result = service.execute

      # Check that the non-beckn enabled school does not show up
      expect(result[:message][:catalog][:providers]).not_to include(
        hash_including(id: school_not_in_beckn.id.to_s),
      )

      # Check that the non-beckn enabled course does not show up
      school_1_result =
        result[:message][:catalog][:providers].find do |provider|
          provider[:id] == school_1.id.to_s
        end
      school_2_result =
        result[:message][:catalog][:providers].find do |provider|
          provider[:id] == school_2.id.to_s
        end

      expect(school_1_result[:items]).not_to include(
        hash_including(id: course_3_s1.id.to_s),
      )
      expect(school_2_result[:items]).not_to include(
        hash_including(id: course_2_s2.id.to_s),
      )
    end
  end
end
