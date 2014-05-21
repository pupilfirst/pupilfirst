path = "#{__FILE__.match(/v\d/)[0]}/startups/startup"
json.partial! path, startup: @startup
