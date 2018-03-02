import React from "react";
import PropTypes from "prop-types";
import TargetStatusBadge from "./TargetStatusBadge";

export default class TargetHeader extends React.Component {
  constructor(props) {
    super(props);
    this.handleClick = this.handleClick.bind(this);
  }

  target() {
    return _.find(this.props.rootState.targets, ["id", this.props.targetId]);
  }

  role() {
    return this.target().role === "founder" ? "Individual" : "Team";
  }

  targetType() {
    if (this.props.currentLevel === 0 || this.props.hasSingleFounder) {
      return null;
    } else {
      return (
        <span className="founder-dashboard-target-header__type-tag">
          {this.role()}:
        </span>
      );
    }
  }

  pointsEarnable() {
    if (
      typeof this.target().points_earnable === "undefined" ||
      this.target().points_earnable === null
    ) {
      return null;
    } else {
      return (
        <div className="founder-dashboard-target-header__info-subtext founder-dashboard-target-header__karma-points font-regular d-none d-md-inline-block">
          Karma Points:
          <span className="founder-dashboard-target-header__info-value">
            {this.target().points_earnable}
          </span>
        </div>
      );
    }
  }

  targetDateString() {
    if (this.props.displayDate) {
      return this.sessionAtString();
    } else {
      return this.daysToCompleteString();
    }
  }

  sessionAtString() {
    if (
      typeof this.target().session_at === "undefined" ||
      this.target().session_at === null
    ) {
      return null;
    } else {
      return (
        <span>
          Session at:
          <span className="founder-dashboard-target-header__info-value">
            {moment(this.target().session_at).format("MMM D, h:mm A")}
          </span>
        </span>
      );
    }
  }

  daysToCompleteString() {
    if (
      typeof this.target().days_to_complete === "undefined" ||
      this.target().days_to_complete === null
    ) {
      return null;
    } else {
      let daysString = "" + this.target().days_to_complete;

      if (this.target().days_to_complete === 1) {
        daysString += " day";
      } else {
        daysString += " days";
      }

      return (
        <span>
          Time required:
          <span className="founder-dashboard-target-header__info-value">
            {daysString}
          </span>
        </span>
      );
    }
  }

  headerIcon() {
    if (
      typeof this.target().session_at === "undefined" ||
      this.target().session_at === null
    ) {
      return this.target().role === "founder"
        ? this.props.rootProps.iconPaths.personalTodo
        : this.props.rootProps.iconPaths.teamTodo;
    } else {
      return this.props.rootProps.iconPaths.attendSession;
    }
  }

  handleClick(event) {
    // highlight the selected target
    $(".founder-dashboard-target-header__container").removeClass(
      "founder-dashboard-target-header__container--active"
    );

    event.target
      .closest(".founder-dashboard-target-header__container")
      .classList.add("founder-dashboard-target-header__container--active");

    // Open the overlay.
    this.props.setRootState({});

    this.props.selectTargetCB(this.props.targetId);
  }

  render() {
    return (
      <div
        className="founder-dashboard-target-header__container clearfix"
        onClick={this.handleClick}
      >
        <img
          className="founder-dashboard-target-header__icon"
          src={this.headerIcon()}
        />

        <div className="founder-dashboard-target-header__title">
          <h6 className="founder-dashboard-target-header__headline">
            {this.targetType()}
            {this.target().title}
          </h6>
        </div>
        <div className="founder-dashboard-target-header__status-badge-block">
          <TargetStatusBadge target={this.target()} />
        </div>
      </div>
    );
  }
}

TargetHeader.propTypes = {
  targetId: PropTypes.number,
  rootProps: PropTypes.object.isRequired,
  rootState: PropTypes.object.isRequired,
  setRootState: PropTypes.func.isRequired,
  selectTargetCB: PropTypes.func.isRequired,
  hasSingleFounder: PropTypes.bool
};
