FactoryGirl.define do
  factory :course_module do
    name { Faker::Lorem.words(3).join ' ' }
    publish_at { 7.days.ago }

    trait :with_2_chapters do
      after(:create) do |course_module|
        create :module_chapter, chapter_number: 1, course_module: course_module
        create :module_chapter, chapter_number: 2, course_module: course_module
      end
    end
  end
end
