after 'development:schools', 'development:founders', 'development:faculty', 'development:courses' do
  puts 'Seeding community'

  school = School.find_by(name: 'SV.CO')
  john_doe = User.find_by(email: 'johndoe@example.com')
  groot = User.find_by(email: 'groot@example.org')
  rocket = User.find_by(email: 'rocket@example.org')
  mickey = User.find_by(email: 'mickeymouse@example.com')
  donald = User.find_by(email: 'donaldduck@example.com')
  community = Community.create!(name: "VR", school: school)

  3.times do
    [john_doe, mickey, groot, rocket, donald].each do |user_1|
      question = Question.create!(
        title: Faker::Lorem.sentence,
        community: community,
        user: user_1
      )
      question.markdown_versions.create!(
        value: Faker::Lorem.paragraph(sentence_count = 10, supplemental = false, random_sentences_to_add = 5),
      )
      question.markdown_versions.create!(
        value: Faker::Lorem.paragraph(sentence_count = 10, supplemental = false, random_sentences_to_add = 5),
        latest: true
      )
      [john_doe, mickey, groot, rocket, donald].each do |user_2|

        next if user_1 == user_2

        answer = Answer.create!(
          question: question,
          user: user_2
        )
        answer.markdown_versions.create!(
          value: Faker::Lorem.paragraph(sentence_count = 10, supplemental = false, random_sentences_to_add = 5)
        )
        answer.markdown_versions.create!(
          value: Faker::Lorem.paragraph(sentence_count = 10, supplemental = false, random_sentences_to_add = 5),
          latest: true
        )
        AnswerLike.create!(
          answer: answer,
          user: [john_doe, mickey, groot, rocket, donald].sample
        )
        answer.comments.create!(
          user: [john_doe, mickey, groot, rocket, donald].sample,
          value: Faker::Lorem.paragraph(sentence_count = 4, supplemental = false, random_sentences_to_add = 5)
        )
        question.touch(:last_activity_at)
      end

      [john_doe, mickey, groot, rocket, donald].each do |user_3|
        question.comments.create!(
          user: user_3,
          value: Faker::Lorem.paragraph(sentence_count = 4, supplemental = false, random_sentences_to_add = 5)
        )
      end
    end
  end

  course = Course.find_by(name: "VR")
  CommunityCourseConnection.create!(course: course, community: community)
end
