require 'discordrb'
require 'csv'
require 'json'

notifications    = CSV.read('notifications.csv')
secrets          = JSON.parse(File.read('secrets.json'))
token            = secrets['token']

admin_id         = secrets['admin_id'].to_i
announcer_id     = secrets['announcer_id'].to_i       # guilded
voice_channel_id = secrets['voice_channel_id'].to_i   # voice 1

WHITE_CHECK_MARK = "\u2705"

def calculate_missing(bot, event)
  missing   = []
  attending = event.message.reacted_with(WHITE_CHECK_MARK)
  present   = bot.channel(voice_channel_id).users

  attending.each do |user|
    missing.push(user) if !present.include?(user) && user.id != announcer_id
  end

  return missing
end

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Bot Definition
bot = Discordrb::Bot.new token: token

bot.message(start_with: 'Your event') do |event|
  if event.message.author.id == announcer_id
    sleep(1800)
    p 'Antagonizing missing players.'

    missing = calculate_missing(bot, event)
    while !missing.empty?
      missing.each do |victim|
        event.respond victim.mention + " " + notifications.sample
      end
      sleep(5)
      missing = calculate_missing(bot, event)
    end

    p 'Finished antagonizing missing players.'
  end
end

bot.run
