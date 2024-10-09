require "rails_helper"

RSpec.describe Mutations::MoveCourse, type: :request do
  include TokenAuthHelper

  let!(:school) { create :school, :current }
  let(:user) { create :user, :with_password, school: school }

  let!(:school_admin) { create :school_admin, user: user }
  let!(:courses) { create_list(:course, 5, school: school) }

  before(:each) { @headers = request_spec_headers(user) }

  def graphql_request(id, target_position_course_id)
    post(
      "/graphql",
      params: {
        query: move_course_query,
        variables: {
          id: id,
          targetPositionCourseId: target_position_course_id
        }.to_json
      },
      as: :json,
      headers: @headers
    )

    JSON.parse(response.body)
  end

  def move_course_query
    <<~'GRAPHQL'
      mutation MoveCourseMutation($id: ID!, $targetPositionCourseId: ID!) {
        moveCourse(id: $id, targetPositionCourseId: $targetPositionCourseId) {
          success
        }
      }
    GRAPHQL
  end

  def move_and_assert_order(
    course_1,
    c1_expected_position,
    course_2,
    c2_expected_position
  )
    response = graphql_request(course_1.id, course_2.id)

    # The request should be a success.
    expect(response.fetch("data").fetch("moveCourse").fetch("success")).to be(
      true
    )

    updated_order = school.courses.order(sort_index: :asc).pluck(:id)

    # The course should be in the expected position.
    expect(updated_order[c1_expected_position]).to eq(course_1.id)
    expect(updated_order[c2_expected_position]).to eq(course_2.id)
  end

  it "rearranges sort_index when moving a course down" do
    move_and_assert_order(courses[2], 4, courses[4], 2)
  end

  it "rearranges sort_index when moving a course up" do
    move_and_assert_order(courses[4], 0, courses[0], 4)
  end

  it "does not move the course when supplied with invalid course1" do
    response = graphql_request(999, courses.first.id)

    expect(response["errors"][0]["message"]).to include("Course not found")
  end

  it "returns an error message when the course is not found" do
    response = graphql_request("invalid", "Up")

    expect(response.fetch("errors").first.fetch("message")).to include(
      "Course not found"
    )
  end

  it "does not move the course when supplied with invalid course2" do
    response = graphql_request(courses.first.id, 999)

    expect(response.dig("data", "moveCourse", "success")).to eq(false)
  end

  context "when sort_index of courses is not sequential" do
    before do
      indexes = [10, 25, 66, 99, 205]
      courses.each_with_index do |course, index|
        course.update!(sort_index: indexes[index])
      end
    end
    it "should reset the sort_index of all the courses into sequential order" do
      expect(
        arithmetic_sequence?(
          school.courses.order(:sort_index).pluck(:sort_index)
        )
      ).to eq(false)

      move_and_assert_order(courses.first, 4, courses.last, 0)

      expect(
        arithmetic_sequence?(
          school.courses.order(:sort_index).pluck(:sort_index)
        )
      ).to eq(true)
    end

    def arithmetic_sequence?(array)
      return true if array.length < 2

      difference = array[1] - array[0]
      array.each_cons(2).all? { |a, b| b - a == difference }
    end
  end
end
