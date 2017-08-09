class FounderDashboardLevelUpNotification extends React.Component {
  eligibleNotificationTitle() {
    if (this.props.currentLevel === 0) {
      return 'Congratulations! You are now SV.CO Founders.';
    } else if (this.props.currentLevel === this.props.maxLevelNumber) {
      return 'Congratulations! You are now part of our Alumni.';
    } else {
      return 'Ready to Level Up!';
    }
  }

  eligibleNotificationText() {
    if (this.props.currentLevel === 0) {
      return 'You have successfully completed the first step in your startup journey. We are proud to have you join our collective. Hit Level Up to continue your journey and unlock a series of cool targets and sessions on the way.';
    } else if (this.props.currentLevel === this.props.maxLevelNumber) {
      return (
        <div><h4 className="font-regular light-grey-text">You've completed our Level Framework, but you know by now that
          this is just the beginning of your startup journey.</h4><p> Thanks for sharing your life experiences with
          SV.CO. Hope this has been an awesome experience. For graduation options & access to the Alumni network, write
          to <a href='mailto:graduation@sv.co'>graduation@sv.co</a></p></div>);
    } else {
      return 'Congratulations! You have successfully completed all milestone targets required to level up. Click the button below to proceed to the next level. New challenges await!';
    }
  }

  render() {
    return (
      <div className="founder-dashboard-levelup-notification__container p-x-1 m-x-auto">
        {this.props.levelUpEligibility === 'eligible' &&
        <div className="founder-dashboard-levelup-notification__box text-xs-center p-a-3">
          <h1>{'\uD83C\uDF89'}</h1>
          <h3 className="brand-primary font-regular">{this.eligibleNotificationTitle()}</h3>

          <div className="founder-dashboard-levelup__description m-x-auto">
            {this.eligibleNotificationText()}
          </div>

          {this.props.currentLevel != this.props.maxLevelNumber &&
          <form className="m-t-2" action="/founder/startup/level_up" acceptCharset="UTF-8" method="post">
            <input name="utf8" type="hidden" value="✓"/>
            <input type="hidden" name="authenticity_token" value={this.props.authenticityToken}/>

            <button className="btn btn-with-icon btn-md btn-primary btn-founder-dashboard-level-up text-uppercase"
              type="submit">
              <i className="fa fa-arrow-right"/>
              Level Up
            </button>
          </form>
          }
        </div>
        }

        {this.props.levelUpEligibility === 'cofounders_pending' &&
        <div className="founder-dashboard-levelup-notification__box text-xs-center p-a-3">
          <h3 className="brand-primary font-regular">Almost ready to level up!</h3>

          <p className="founder-dashboard-levelup__description m-x-auto">
            There are one or more milestone targets that your co-founders are yet to complete. Please contact them
            and ask them to sign in and complete these targets to be eligible to level up!
          </p>
        </div>
        }
      </div>
    );
  }
}

FounderDashboardLevelUpNotification.propTypes = {
  authenticityToken: React.PropTypes.string,
  levelUpEligibility: React.PropTypes.string,
  currentLevel: React.PropTypes.number,
  maxLevelNumber: React.PropTypes.number
};
