import React from "react";
import PropTypes from "prop-types";
import TargetStatusBadge from "./TargetStatusBadge";

export default class TargetHeader extends React.Component {
  constructor(props) {
    super(props);
    this.handleClick = this.handleClick.bind(this);
  }

  targetType() {
    if (this.props.currentLevel === 0) {
      return null;
    } else {
      return (
        <span className="founder-dashboard-target-header__type-tag">
        {this.props.target.target_type_description}:
        </span>
      );
    }
  }

  pointsEarnable() {
    if (
      typeof this.props.target.points_earnable === "undefined" ||
      this.props.target.points_earnable === null
    ) {
      return null;
    } else {
      return (
        <div className="founder-dashboard-target-header__info-subtext founder-dashboard-target-header__karma-points font-regular d-none d-md-inline-block">
          Karma Points:
          <span className="founder-dashboard-target-header__info-value">
            {this.props.target.points_earnable}
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
      typeof this.props.target.session_at === "undefined" ||
      this.props.target.session_at === null
    ) {
      return null;
    } else {
      return (
        <span>
          Session at:
          <span className="founder-dashboard-target-header__info-value">
            {moment(this.props.target.session_at).format("MMM D, h:mm A")}
          </span>
        </span>
      );
    }
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
          <span className="founder-dashboard-target-header__info-value">
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

  handleClick(event) {
    // highlight the selected target
    $(".founder-dashboard-target-header__container").removeClass(
      "founder-dashboard-target-header__container--active"
    );
    event.target
      .closest(".founder-dashboard-target-header__container")
      .classList.add("founder-dashboard-target-header__container--active");

    this.props.onClickCB(this.props.target.id, this.props.target.target_type);
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
            {this.props.target.title}
          </h6>

          {/*<div className="founder-dashboard-target-header__headline-info">*/}
            {/*<div className="founder-dashboard-target-header__info-subtext font-regular">*/}
              {/*{this.targetDateString()}*/}
              {/*{this.pointsEarnable()}*/}
            {/*</div>*/}
          {/*</div>*/}
        </div>
        <div className="founder-dashboard-target-header__status-badge-block">
          <TargetStatusBadge target={this.props.target} />
        </div>
      </div>
    );
  }
}

TargetHeader.propTypes = {
  currentLevel: PropTypes.number,
  onClickCB: PropTypes.func,
  target: PropTypes.object,
  displayDate: PropTypes.bool,
  iconPaths: PropTypes.object
};

TargetHeader.defaultProps = {
  displayDate: false
};
