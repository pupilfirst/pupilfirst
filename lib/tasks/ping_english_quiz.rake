desc 'DM all slack-connected founders the English question for the day'
task ping_english_quiz: :environment do
  PublicSlack::PostEnglishQuestionService.new.post
end
