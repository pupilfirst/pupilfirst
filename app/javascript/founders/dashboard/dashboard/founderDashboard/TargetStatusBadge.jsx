import React from "react";
import PropTypes from "prop-types";

export default class TargetStatusBadge extends React.Component {
  containerClasses() {
    let classes =
      "founder-dashboard-target-status-badge__container badge badge-pill";
    let statusClass = this.props.target.status.replace("_", "-");
    classes += " " + statusClass;
    return classes;
  }

  statusIconClasses() {
    return {
      passed: "fa fa-thumbs-o-up",
      failed: "fa fa-thumbs-o-down",
      submitted: "fa fa-hourglass-half",
      pending: "fa fa-clock-o",
      level_locked: "fa fa-eye",
      milestone_locked: "fa fa-lock",
      prerequisite_locked: "fa fa-lock"
    }[this.props.target.status];
  }

  statusString() {
    return {
      passed: "Passed",
      failed: "Failed",
      submitted: "Submitted",
      pending: "Pending",
      level_locked: "Preview",
      milestone_locked: "Locked",
      prerequisite_locked: "Locked"
    }[this.props.target.status];
  }

  statusContents() {
    return (
      <span>
          <span className="founder-dashboard-target-header__status-badge-icon">
            <i className={this.statusIconClasses()} />
          </span>

          <span>{this.statusString()}</span>
        </span>
    );
  }

  render() {
    return (
      <div className={this.containerClasses()}>{this.statusContents()}</div>
    );
  }
}

TargetStatusBadge.propTypes = {
  target: PropTypes.object
};
