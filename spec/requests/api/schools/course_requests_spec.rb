require 'rails_helper'

module Api
  module Schools
    describe 'Courses endpoints' do
      let!(:keycloak_client) { Rails.configuration.keycloak_client }
      let(:user_email) { 'test@test.com' }
      let(:user_password) { 'testtest' }
      let(:access_token) do
        keycloak_client.user_token(user_email, user_password)
      end
      let(:headers) do
        {
          'ACCEPT' => 'application/json',
          'Authorization' => "Bearer #{access_token}"
        }
      end
      let!(:domain) { create :domain, fqdn: host, primary: true }
      let!(:school) do
        scl = domain.school

        user = create :user, name: 'Test Test', email: user_email, school: scl
        school_admin = create :school_admin, user: user

        scl.school_admins << school_admin

        scl
      end

      before :each do
        keycloak_client.create_user(user_email, 'Test', 'Test')
        keycloak_client.set_user_password(user_email, user_password)
      end

      context 'index' do
        it 'returns all courses of current_school' do
          courses = create_list :course, 3, school: school

          get '/api/schools/courses', headers: headers

          expect(response).to have_http_status(:ok)
          expect(response.body).to eq(courses.to_json)
        end
      end

      context 'students' do
        let!(:course) do
          create :course, :with_one_level, school: school
        end

        let!(:students) do
          student_structs = 4.times.map { |i| OpenStruct.new(name: "Test#{i}", email: "test#{i}@test.com") }
          student_ids = ::Courses::AddStudentsService.new(course, notify: false).add(student_structs)
          User.joins(:founders).where(founders: { id: student_ids })
        end

        it 'returns all students of a course' do
          get "/api/schools/courses/#{course.id}/students", headers: headers

          expected_students = students.map { |std| { name: std.name, email: std.email } }
          expect(response).to have_http_status(:ok)
          expect(response.body).to eq({students: expected_students}.to_json)
        end
      end

      context 'create_students' do
        let!(:course) do
          crs = create :course, :with_one_level, school: school
        end

        it 'register students into a course' do
          params = {
            students: [
              {name: 'Test1', email: 'test1@test.com'},
              {name: 'Test2', email: 'test2@test.com'}
            ]
          }
          expect {
            post "/api/schools/courses/#{course.id}/students", params: params, headers: headers
          }.to change{ course.users.count }.by(2)
          expect(response).to have_http_status(:created)
        end

        it 'always notify registered students' do
          params = {
            students: [
              {name: 'Test1', email: 'test1@test.com'},
              {name: 'Test2', email: 'test2@test.com'}
            ]
          }
          form = Students::CreateForm.new(Reform::OpenForm.new) 
          allow(Students::CreateForm).to receive(:new) { form }
          expect(::Courses::AddStudentsService).to receive(:new).with(course, hash_including(notify: true)) { form }
          post "/api/schools/courses/#{course.id}/students", params: params, headers: headers
        end
      end
    end
  end
end
