require 'rails_helper'

RSpec.describe Mutations::MoveCourse, type: :request do
  include TokenAuthHelper

  let!(:school) { create :school, :current }
  let(:user) { create :user, :with_password, school: school }

  let!(:school_admin) { create :school_admin, user: user }
  let!(:courses) { create_list(:course, 5, school: school) }

  before(:each) do
    @headers = request_spec_headers(user)
  end

  def graphql_request(id, direction)
    post('/graphql', params: { query: move_course_query, variables: { id: id, direction: direction }.to_json },
         as: :json, headers: @headers)
  end

  context 'when moving course up or down' do
    it 'rearranges the courses order when moving up' do
      move_and_assert_order('Up', courses[2])
    end

    it 'rearranges the courses order when moving down' do
      move_and_assert_order('Down', courses[2])
    end
  end

  context 'when course is not present' do
    it 'returns an error message' do
      graphql_request(999, 'Up')

      json_response = JSON.parse(response.body)
      expect(json_response['errors'][0]['message']).to include('Course not found')

    end
  end

  def move_course_query
    <<~'GRAPHQL'
      mutation MoveCourseMutation($id: ID!,$direction: MoveDirection!) {
        moveCourse(id:$id,direction:$direction) {
          success
        }
      }
    GRAPHQL
  end

  def move_and_assert_order(direction, moved_course)
    original_order = school.courses.order(sort_index: :asc).to_a
    graphql_request(moved_course.id, direction)

    json_response = JSON.parse(response.body)
    expect(json_response['data']['moveCourse']['success']).to be(true)

    updated_order = school.courses.order(sort_index: :asc).to_a
    expect(updated_order).not_to eq(original_order)
  end
end
