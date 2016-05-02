require_relative 'helper'

after 'development:startups' do
  avengers_startup = Startup.find_by(product_name: 'SuperHeroes')

  targets_list = [
    [avengers_startup, Faculty.first, 'founder', 'Upload Resume', 'Upload your latest resume!', 'done'],
    [avengers_startup, Faculty.second, 'engineering', 'Select Tech Stack', 'Decide on the tech stack that works for you', 'pending'],
    [avengers_startup, Faculty.first, 'governance', 'Sign Agreements', 'Complete all your paperwork with SV.CO', 'pending']
  ]

  targets_list.each do |startup, assigner, role, title, description, status|
    Target.create!(
      assignee: startup,
      assigner: assigner,
      role: role,
      title: title,
      description: description,
      status: status
    )
  end

  Target.last.update(due_date: 1.week.ago)
end
