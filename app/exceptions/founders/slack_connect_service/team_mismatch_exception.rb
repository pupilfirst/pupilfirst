module Founders
  class SlackConnectService
    # Raised when the team the user is signing into doesn't match the one we want them to sign into (Public Slack)
    class TeamMismatchException < StandardError
    end
  end
end
