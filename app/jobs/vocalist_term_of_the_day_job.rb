class VocalistTermOfTheDayJob < ApplicationJob
  queue_as :default

  def perform(channel)
    term = GlossaryTerm.limit(1).order('RANDOM()').first

    message = <<~MESSAGE
      #{salutation}
      > *#{term.term.upcase}*
      > _*Definition:* #{term.definition}_
    MESSAGE

    PublicSlack::MessageService.new.execute message: message, channel: channel
  end

  def salutation
    [
      'Good Morning Everyone! :simple_smile: Here is the *Term of the Day* :',
      'Lovely Day Ahead! :upside_down_face: And the *Term for Today* is:',
      "It's a beautiful #{Time.now.strftime('%A')} morning! :sun_with_face: Here is your *Term for Today*:"
    ].sample
  end
end
