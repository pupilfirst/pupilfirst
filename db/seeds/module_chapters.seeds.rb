after 'course_modules' do
  puts 'Seeding module_chapters (idempotent)'

  module_1 = CourseModule.find_by(module_number: 1)
  module_2 = CourseModule.find_by(module_number: 2)
  module_3 = CourseModule.find_by(module_number: 3)
  module_4 = CourseModule.find_by(module_number: 4)

  ModuleChapter.where(course_module: module_1, chapter_number: 1).first_or_create!(name: 'Before You Begin')
  ModuleChapter.where(course_module: module_1, chapter_number: 2).first_or_create!(name: 'Tips for Teachers',)

  ModuleChapter.where(course_module: module_2, chapter_number: 1).first_or_create!(
    name: 'Building Skills',
    links: [
      {
        title: 'Inc. article about how working together (collaboration) is better than competition',
        url: 'http://www.inc.com/laura-montini/infographic/how-teams-drive-innovation-productivity-and-growth.html'
      },
      {
        title: 'Paul Graham (Y Combinator founder) talks about why to start up early',
        url: 'http://paulgraham.com/notnot.html'
      },
      {
        title: "This Quora thread answers a question that's asked often: 'What happens if I fail at my startup?'",
        url: 'https://www.quora.com/What-are-the-career-options-for-a-founder-of-a-failed-startup-What-jobs-view-this-as-attractive-experience'
      }
    ]
  )

  ModuleChapter.where(course_module: module_2, chapter_number: 2).first_or_create!(
    name: 'Learn How to Learn',
    links: [
      {
        title: 'The Emerging future illustration depicts accelerating technology change and how humans perceive it',
        url: 'http://theemergingfuture.com/speed-technological-advancement.htm'
      },
      {
        title: 'The P21 partnership for 21st century learning has resources describing Creativity and Innovation',
        url: 'http://www.p21.org/about-us/p21-framework/262'
      },
      {
        title: 'This Wikipedia entry on Experiential describes how everybody can learn by doing',
        url: 'https://en.wikipedia.org/wiki/Experiential_learning'
      }
    ]
  )

  ModuleChapter.where(course_module: module_2, chapter_number: 3).first_or_create!(
    name: 'Six Ways',
    links: [
      {
        title: 'Stripe, a payment company in the US now accepts applications for jobs as a team.',
        url: 'https://stripe.com/blog/bring-your-own-team'
      },
      {
        title: '37Signals has a great list of startups who are self-sustainable.',
        url: 'http://37signals.com/bootstrapped'
      },
      {
        title: 'This Quora thread describes qualities of a good startup engineering hire.',
        url: 'https://www.quora.com/What-qualities-make-a-good-startup-engineer'
      }
    ]
  )

  ModuleChapter.where(course_module: module_2, chapter_number: 4).first_or_create!(
    name: 'Starting Early',
    links: [
      {
        title: 'A Entrepreneurship.org article that talks about effective ROI.',
        url: 'http://entrepreneurship.org/resource-center/startup-premoney-valuation--the-keystone-to-return-on-investment.aspx'
      },
      {
        title: "Sequoia Capital's Elements of Enduring Companies is a great read.",
        url: 'https://www.sequoiacap.com/india/article/elements-of-enduring-companies/'
      },
      {
        title: 'The Startup Genome report talks the different stages of a Startup Lifecycle journey.',
        url: 'http://www.slideshare.net/Startupi/startup-genome-report'
      }
    ]
  )

  ModuleChapter.where(course_module: module_2, chapter_number: 5).first_or_create!(
    name: 'Jobs',
    links: [
      {
        title: 'This article in the Hindu talks about how India will become the youngest country in the world by 2020.',
        url: 'http://www.thehindu.com/news/national/india-is-set-to-become-the-youngest-country-by-2020/article4624347.ece'
      },
      {
        title: 'Livemint has talks about how Indian IT firms have slowed down hiring.',
        url: 'http://www.livemint.com/Industry/V2sW6rBYoXuH9HNMfb7d9M/Indian-IT-firms-in-no-mood-to-hire.html'
      },
      {
        title: 'Quartz has a great interview with the author of the Sharing Economy, Arun Sundararajan.',
        url: 'http://qz.com/710515/arun-on-sharing-economy/'
      }
    ]
  )

  ModuleChapter.where(course_module: module_2, chapter_number: 6).first_or_create!(name: 'Prepare for Quiz')

  ModuleChapter.where(course_module: module_3, chapter_number: 1).first_or_create!(name: 'Baby Business')
  ModuleChapter.where(course_module: module_3, chapter_number: 2).first_or_create!(name: 'Waves')
  ModuleChapter.where(course_module: module_3, chapter_number: 3).first_or_create!(name: 'Kinds')
  ModuleChapter.where(course_module: module_3, chapter_number: 4).first_or_create!(name: 'What Startups are Not')
  ModuleChapter.where(course_module: module_3, chapter_number: 5).first_or_create!(name: 'Prepare for Quiz')

  ModuleChapter.where(course_module: module_4, chapter_number: 1).first_or_create!(name: 'Three Roles')
  ModuleChapter.where(course_module: module_4, chapter_number: 2).first_or_create!(name: 'The Product Role')
  ModuleChapter.where(course_module: module_4, chapter_number: 3).first_or_create!(name: 'The Design Role')
  ModuleChapter.where(course_module: module_4, chapter_number: 4).first_or_create!(name: 'The Engineering Role')
end
