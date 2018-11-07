require_relative 'helper'

puts 'Seeding Evaluation Criteria'

EvaluationCriterion.create!(name: 'User Empathy', description: "Ability to put yourself in the user's shoes, and think from the user's PoV")
EvaluationCriterion.create!(name: 'Data Driven Bias', description: "Take decisions & perform activities not based on intuition, but qualitative and quantitative analysis.")
