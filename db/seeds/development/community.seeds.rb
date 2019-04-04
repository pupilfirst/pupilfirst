after 'development:schools', 'development:founders' do
  puts 'Seeding community'

  school = School.find_by(name: 'SV.CO')
  john_doe = User.find_by(email: 'johndoe@example.com')
  groot = User.find_by(email: 'groot@example.org')
  rocket = User.find_by(email: 'rocket@example.org')
  community = Community.create!(name: "VR", school: school)

  [john_doe, groot, rocket].each do |user|
    question = Question.create!(
      title: Faker::Lorem.sentence,
      description: Faker::Lorem.sentence,
      community: community,
      user: user
    )
    answer = Answer.create!(
      description: Faker::Lorem.sentence,
      question: question,
      user: [john_doe, groot, rocket].sample
    )
    AnswerClap.create!(
      count: 10,
      answer: answer,
      user: [john_doe, groot, rocket].sample
    )
  end
end
