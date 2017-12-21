import React from "react";
import PropTypes from "prop-types";

export default class HeaderTitle extends React.Component {
  targetType() {
    return (
      <span className="target-overlay-header__type-tag">
        {this.props.target.target_type_description}:
      </span>
    );
  }

  pointsEarnable() {
    if (
      typeof this.props.target.points_earnable === "undefined" ||
      this.props.target.points_earnable === null
    ) {
      return null;
    } else {
      return (
        <div className="target-overlay-header__info-subtext target-overlay-header__karma-points font-regular d-none d-md-inline-block">
          Karma Points:
          <span className="target-overlay-header__info-value">
            {this.props.target.points_earnable}
          </span>
        </div>
      );
    }
  }

  targetDateString() {
    if (
      typeof this.props.target.session_at === "undefined" ||
      this.props.target.session_at === null
    ) {
      return this.daysToCompleteString();
    } else {
      return this.sessionAtString();
    }
  }

  sessionAtString() {
    return (
      <span>
        Session at:
        <span className="target-overlay-header__info-value">
          {moment(this.props.target.session_at).format("MMM D, h:mm A")}
        </span>
      </span>
    );
  }

  daysToCompleteString() {
    if (
      typeof this.props.target.days_to_complete === "undefined" ||
      this.props.target.days_to_complete === null
    ) {
      return null;
    } else {
      let daysString = "" + this.props.target.days_to_complete;

      if (this.props.target.days_to_complete === 1) {
        daysString += " day";
      } else {
        daysString += " days";
      }

      return (
        <span>
          Time required:
          <span className="target-overlay-header__info-value">
            {daysString}
          </span>
        </span>
      );
    }
  }

  headerIcon() {
    if (
      typeof this.props.target.session_at === "undefined" ||
      this.props.target.session_at === null
    ) {
      return this.props.target.role === "founder"
        ? this.props.iconPaths.personalTodo
        : this.props.iconPaths.teamTodo;
    } else {
      return this.props.iconPaths.attendSession;
    }
  }

  render() {
    return (
      <div className="founder-dashboard-target-header__content">
        <img
          className="founder-dashboard-target-header__icon"
          src={this.headerIcon()}
        />
        <div className="target-overlay-header__title">
          <h6 className="target-overlay-header__headline">
            {this.targetType()}
            {this.props.target.title}
          </h6>

          <div className="target-overlay-header__headline-info">
            <div className="target-overlay-header__info-subtext font-regular">
              {this.targetDateString()}
              {this.pointsEarnable()}
            </div>
          </div>
        </div>
      </div>
    );
  }
}

HeaderTitle.propTypes = {
  target: PropTypes.object,
  iconPaths: PropTypes.object
};
