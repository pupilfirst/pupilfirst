class FounderDashboardLevelUpNotification extends React.Component {
  render() {
    return (
      <div className="founder-dashboard-levelup-notification__container p-x-1 m-x-auto">
        { this.props.levelUpEligibility === 'eligible' &&
        <div className="founder-dashboard-levelup-notification__box text-xs-center p-a-3">
          <h1>{ '\uD83C\uDF89' }</h1>
          <h3 className="brand-primary font-regular">Ready to Level Up!</h3>

          <p className="founder-dashboard-levelup__description m-x-auto">
            Congratulations! You have successfully completed all milestone targets required to level up. Click the
            button below to proceed to the next level. New challenges await!
          </p>

          <form className="m-t-2" action="/founder/startup/level_up" acceptCharset="UTF-8" method="post">
            <input name="utf8" type="hidden" value="✓"/>
            <input type="hidden" name="authenticity_token" value={ this.props.authenticityToken }/>

            <button className="btn btn-with-icon btn-md btn-primary btn-founder-dashboard-level-up text-uppercase"
              type="submit">
              <i className="fa fa-arrow-right"/>
              Level Up
            </button>
          </form>
        </div>
        }

        { this.props.levelUpEligibility === 'cofounders_pending' &&
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
  levelUpEligibility: React.PropTypes.string
};
