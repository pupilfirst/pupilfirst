require_relative "helper"

after "development:targets" do
  puts "Seeding quiz"

  course = Course.find_by(name: "VR")
  level = course.levels.where.not(number: 0).first
  target_group = level.target_groups.first
  # Auto verify target for Quiz.
  target = target_group.targets.create!(days_to_complete: [7, 10, 14].sample,
                                        title: "Quiz target for VR course",
                                        role: Target.valid_roles.sample,
                                        target_group: target_group,
                                        description: paragraph,
                                        faculty: Faculty.first,
                                        target_action_type: Target::TYPE_TODO,
                                        submittability: Target::SUBMITTABILITY_AUTO_VERIFY)
  quiz = Quiz.create!(
    title: Faker::Lorem.sentence,
    target: target,
  )

  question = QuizQuestion.create!(
    question: "Is Fin Robotics a successful business?",
    description: Faker::Lorem.sentence,
    quiz: quiz,
  )

  question.answer_options.create!(
    value: "Yes. They raised funding!",
    hint: "Raising funding is not a measure of success. Its only a measure of early validation. That somebody - aside from yourself - believes in your product enough to invest money in you. To become a successful business, you have to generate returns for your shareholders.",
  )

  question.answer_options.create!(
    value: "Yes. The founders learnt a lot.",
    hint: "Learning is a good goal to have when starting up. Even at a failed startup, founders learn a lot.",
  )

  question.answer_options.create!(value: "No. They havent generated profits for shareholders.")

  correct_answer = question.answer_options.create!(
    value: "Cant Say. They still have a long way to go.",
    hint: "Thats right, they still have a long way to go.",
  )

  question.update!(correct_answer: correct_answer)

  question = QuizQuestion.create!(
    question: "Fin Robotics went through four failed products before building Fin. Was that a good thing?",
    quiz: quiz,
  )

  question.answer_options.create!(
    value: "No. Failure is never good.",
    hint: "Failure is at times a learning experience. Most good startups fail before they succeed.",
  )

  correct_answer = question.answer_options.create!(
    value: "Yes. Each failure taught Rohildev lots of valuable skills.",
    hint: "This is correct. Failure by itself is not a thing to look forward to. But each unsuccessful try teaches founders lots of valuable lessons. This could be information about their market segment, or their customers. Or how to build a different product from the information they learnt.",
  )

  question.answer_options.create!(
    value: "Yes. Failure is cool!",
    hint: "Failure is not cool. Of a thousand startups, maybe 1 or 2 succeed and we hear about their success stories in newspapers and on TV. We never hear about failures and the difficult times founders go through. The only thing good about failures is when you use that opportunity to learn from failure.",
  )

  question.answer_options.create!(
    value: "All of the above",
    hint: "Half correct! Failure by itself is not cool in any way. Of a thousand startups, maybe 1 or 2 succeed and we hear about their success stories in newspapers and on TV. We never hear about failures and the difficult times founders go through. The only thing good about failures is when you use that opportunity to learn from failure.",
  )

  question.update!(correct_answer: correct_answer)
end
