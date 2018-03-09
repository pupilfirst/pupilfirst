import React from "react";
import PropTypes from "prop-types";

export default class LevelUpNotification extends React.Component {
  eligibleNotificationTitle() {
    if (this.currentLevelNumber() === 0) {
      return "Congratulations! You are now an enrolled student at SV.CO.";
    } else if (this.currentLevelNumber() === this.props.maxLevelNumber) {
      return "Congratulations! You are now part of our Alumni.";
    } else {
      return "Ready to Level Up!";
    }
  }

  currentLevelNumber() {
    return this.props.rootProps.currentLevel.number;
  }

  eligibleNotificationText() {
    if (this.currentLevelNumber() === 0) {
      return "You have successfully completed the first step in your journey with SV.CO. We are proud to have you join our collective. Hit Level Up to continue your journey and unlock a series of cool targets and sessions on the way.";
    } else if (this.currentLevelNumber() === this.props.maxLevelNumber) {
      return (
        <div>
          <h4 className="font-regular light-grey-text">
            You've completed our Level Framework, but you know by now that this
            is just the beginning of your journey.
          </h4>
          <p>
            {" "}
            Thanks for sharing your life experiences with SV.CO. Hope this has
            been an awesome experience. For graduation options & access to the
            Alumni network, write to{" "}
            <a href="mailto:graduation@sv.co">graduation@sv.co</a>
          </p>
        </div>
      );
    } else {
      return "Congratulations! You have successfully completed all milestone targets required to level up. Click the button below to proceed to the next level. New challenges await!";
    }
  }

  render() {
    return (
      <div className="founder-dashboard-levelup-notification__container px-2 mx-auto mt-3">
        {this.props.rootProps.levelUpEligibility === "eligible" && (
          <div className="founder-dashboard-levelup-notification__box text-center p-3">
            <h1>{"\uD83C\uDF89"}</h1>
            <h3 className="brand-primary font-regular">
              {this.eligibleNotificationTitle()}
            </h3>

            <div className="founder-dashboard-levelup__description mx-auto">
              {this.eligibleNotificationText()}
            </div>

            {this.currentLevelNumber() !==
              this.props.rootProps.maxLevelNumber && (
              <form
                className="mt-3"
                action="/startup/level_up"
                acceptCharset="UTF-8"
                method="post"
              >
                <input name="utf8" type="hidden" value="✓" />
                <input
                  type="hidden"
                  name="authenticity_token"
                  value={this.props.rootProps.authenticityToken}
                />

                <button
                  className="btn btn-with-icon btn-md btn-primary btn-founder-dashboard-level-up text-uppercase"
                  type="submit"
                >
                  <i className="fa fa-arrow-right" />
                  Level Up
                </button>
              </form>
            )}
          </div>
        )}

        {this.props.rootProps.levelUpEligibility === "cofounders_pending" && (
          <div className="founder-dashboard-levelup-notification__box text-center p-3">
            <h3 className="brand-primary font-regular">
              Almost ready to level up!
            </h3>

            <p className="founder-dashboard-levelup__description mx-auto">
              There are one or more milestone targets that your teammates are
              yet to complete. Please contact them and ask them to sign in and
              complete these targets to unlock the next level.
            </p>
          </div>
        )}

        {this.props.rootProps.levelUpEligibility === "date_locked" && (
          <div className="founder-dashboard-levelup-notification__box text-center p-3">
            <h1>{"\uD83C\uDF89"}</h1>
            <h3 className="brand-primary font-regular">
              Level complete! Please wait for the next one.
            </h3>

            <p className="founder-dashboard-levelup__description mx-auto">
              Congratulations on completing all milestone targets in this level.
              Your next level will be unlocked on{" "}
              <span>
                {moment(this.props.rootProps.nextLevelUnlockDate).format(
                  "MMM D"
                )}
              </span>. Please revisit your dashboard on this date to receive
              your next set of targets. Happy learning!
            </p>
          </div>
        )}
      </div>
    );
  }
}

LevelUpNotification.propTypes = {
  rootProps: PropTypes.object.isRequired
};
