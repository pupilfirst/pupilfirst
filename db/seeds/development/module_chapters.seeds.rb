require_relative 'helper'

after 'development:course_modules' do
  ModuleChapter.create!(
    course_module: CourseModule.find_by_module_number(1),
    name: 'Building Skills',
    chapter_number: 1,
    links: [{"title":"Inc. article about how working together (collaboration) is better than competition","url":"http://www.inc.com/laura-montini/infographic/how-teams-drive-innovation-productivity-and-growth.html"},{"title":"Paul Graham (Y Combinator founder) talks about why to start up early","url":"http://paulgraham.com/notnot.html"},{"title":"This Quora thread answers a question that's asked often: 'What happens if I fail at my startup?'","url":"https://www.quora.com/What-are-the-career-options-for-a-founder-of-a-failed-startup-What-jobs-view-this-as-attractive-experience"}]
  )

  ModuleChapter.create!(
    course_module: CourseModule.find_by_module_number(1),
    name: 'Learn How to Learn',
    chapter_number: 2
  )

  ModuleChapter.create!(
    course_module: CourseModule.find_by_module_number(1),
    name: 'Six Ways',
    chapter_number: 3
  )

  ModuleChapter.create!(
    course_module: CourseModule.find_by_module_number(1),
    name: 'Starting Early',
    chapter_number: 4
  )

  ModuleChapter.create!(
    course_module: CourseModule.find_by_module_number(1),
    name: 'Jobs',
    chapter_number: 5,
    links: [{"title":"This article in the Hindu talks about how India will become the youngest country in the world by 2020.","url":"http://www.thehindu.com/news/national/india-is-set-to-become-the-youngest-country-by-2020/article4624347.ece"},{"title":"Livemint has talks about how Indian IT firms have slowed down hiring.","url":"http://www.livemint.com/Industry/V2sW6rBYoXuH9HNMfb7d9M/Indian-IT-firms-in-no-mood-to-hire.html"},{"title":"Quartz has a great interview with the author of the Sharing Economy, Arun Sundararajan.","url":"http://qz.com/710515/arun-on-sharing-economy/"}]
  )

  ModuleChapter.create!(
    course_module: CourseModule.find_by_module_number(2),
    name: 'Baby Business',
    chapter_number: 1
  )
end
