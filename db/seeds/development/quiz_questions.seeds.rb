require_relative 'helper'

after 'development:module_chapters' do
  puts 'Seeding quiz_questions'

  question = QuizQuestion.new(
    course_module: CourseModule.find_by(module_number: 2),
    question: 'Is Fin Robotics a successful business?'
  )

  question.save(validate: false)

  AnswerOption.create!(
    value: 'Yes. They raised funding!',
    hint_text: 'Raising funding is not a measure of success. Its only a measure of early validation. That somebody—aside from yourself—believes in your product enough to invest money in you. To become a successful business, you have to generate returns for your shareholders.',
    quiz_question: question
  )

  AnswerOption.create!(
    value: 'Yes. The founders learnt a lot.',
    hint_text: 'Learning is a good goal to have when starting up. Even at a failed startup, founders learn a lot.',
    quiz_question: question
  )

  AnswerOption.create!(
    value: 'No. They havent generated profits for shareholders.',
    quiz_question: question
  )

  AnswerOption.create!(
    value: 'Cant Say. They still have a long way to go.',
    correct_answer: true,
    hint_text: 'Thats right, they still have a long way to go.',
    quiz_question: question
  )

  question = QuizQuestion.new(
    course_module: CourseModule.find_by(module_number: 2),
    question: 'Fin Robotics went through four failed products before building Fin. Was that a good thing?'
  )

  question.save(validate: false)

  AnswerOption.create!(
    value: 'a) No. Failure is never good.',
    hint_text: 'Failure is at times a learning experience. Most good startups fail before they succeed.',
    quiz_question: question
  )

  AnswerOption.create!(
    value: 'b) Yes. Each failure taught Rohildev lots of valuable skills.',
    hint_text: 'This is correct. Failure by itself is not a thing to look forward to. But each unsuccessful try teaches founders lots of valuable lessons. This could be information about their market segment, or their customers. Or how to build a different product from the information they learnt.',
    correct_answer: true,
    quiz_question: question
  )

  AnswerOption.create!(
    value: 'Both b and c.',
    hint_text: 'Half correct! Failure by itself is not cool in any way. Of a thousand startups, maybe 1 or 2 succeed and we hear about their success stories in newspapers and on TV. We never hear about failures and the difficult times founders go through. The only thing good about failures is when you use that opportunity to learn from failure.',
    quiz_question: question
  )

  AnswerOption.create!(
    value: 'c) Yes. Failure is cool!',
    hint_text: 'Failure is not cool. Of a thousand startups, maybe 1 or 2 succeed and we hear about their success stories in newspapers and on TV. We never hear about failures and the difficult times founders go through. The only thing good about failures is when you use that opportunity to learn from failure.',
    quiz_question: question
  )
end
