require_relative "helper"

after "development:targets" do
  puts "Seeding quiz"


  Target.where('title LIKE ?', 'Quiz: %').each do |target|
    quiz = Quiz.create!(
      title: Faker::Lorem.sentence,
      target: target,
    )

    # Add the first question with answers.
    question_text = <<~MARKDOWN
      What is the output to STDOUT for the following block of code?

      ```ruby
        def foo(a, b)
          a + b
        end

        puts foo(1, 2)
      ```
    MARKDOWN

    question_1 = quiz.quiz_questions.create!(question: question_text)

    question_1.answer_options.create!(value: "12")
    question_1.answer_options.create!(value: "1 + 2")
    correct_answer_1 = question_1.answer_options.create!(value: "3")
    question_1.answer_options.create!(value: "None of these.")

    question_1.update(correct_answer: correct_answer_1)

    # Add a second question with answers.
    question_2 = quiz.quiz_questions.create!(question: "Which of the following functions will print 11 to STDOUT?")

    correct_answer_2 = question_2.answer_options.create!(
      value: <<~MARKDOWN
        ```ruby
        def foo(a, b)
          a + b
        end

        puts foo("1", "1")
        ```
      MARKDOWN
    )

    question_2.answer_options.create!(
      value: <<~MARKDOWN
        ```ruby
        def foo(a, b)
          a + b
        end

        puts foo(1, 1)
        ```
    MARKDOWN
    )

    question_2.answer_options.create!(
      value: <<~MARKDOWN
        ```ruby
        def foo(a, b)
          "Nope"
        end

        puts foo(1, 1)
        ```
      MARKDOWN
    )

    question_2.update!(correct_answer: correct_answer_2)
  end
end
