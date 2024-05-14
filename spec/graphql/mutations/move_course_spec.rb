require "rails_helper"

RSpec.describe Mutations::MoveCourse, type: :request do
  include TokenAuthHelper

  let!(:school) { create :school, :current }
  let(:user) { create :user, :with_password, school: school }

  let!(:school_admin) { create :school_admin, user: user }
  let!(:courses) { create_list(:course, 5, school: school) }

  before(:each) { @headers = request_spec_headers(user) }

  def graphql_request(id, direction)
    post(
      "/graphql",
      params: {
        query: move_course_query,
        variables: { id: id, direction: direction }.to_json
      },
      as: :json,
      headers: @headers
    )

    JSON.parse(response.body)
  end

  def move_course_query
    <<~'GRAPHQL'
      mutation MoveCourseMutation($id: ID!, $direction: MoveDirection!) {
        moveCourse(id: $id, direction: $direction) {
          success
        }
      }
    GRAPHQL
  end

  def move_and_assert_order(direction, course_to_move:, expected_position:)
    puts "Before: #{school.courses.order(sort_index: :asc).pluck(:id).join(",")}"
    response = graphql_request(course_to_move.id, direction)

    # The request should be a success.
    expect(response["data"]["moveCourse"]["success"]).to be(true)

    puts "After: #{school.courses.order(sort_index: :asc).pluck(:id).join(",")}"
    updated_order = school.courses.order(sort_index: :asc).pluck(:id)

    # The course should be in the expected position.
    expect(updated_order[expected_position]).to eq(course_to_move.id)
  end

  it "rearranges the courses order when moving up" do
    move_and_assert_order(
      "Up",
      course_to_move: courses[2],
      expected_position: 1
    )
  end

  it "rearranges the courses order when moving down" do
    move_and_assert_order(
      "Down",
      course_to_move: courses[2],
      expected_position: 3
    )
  end

  it "does not move the course when it is already at the top" do
    move_and_assert_order(
      "Up",
      course_to_move: courses[0],
      expected_position: 0
    )
  end

  it "does not move the course when it is already at the bottom" do
    move_and_assert_order(
      "Down",
      course_to_move: courses[4],
      expected_position: 4
    )
  end

  it "returns an error message when the course is not found" do
    response = graphql_request(999, "Up")

    expect(response["errors"][0]["message"]).to include("Course not found")
  end
end
