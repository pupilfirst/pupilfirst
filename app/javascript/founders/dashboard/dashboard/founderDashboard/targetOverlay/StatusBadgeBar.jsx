import React from "react";
import PropTypes from "prop-types";

export default class StatusBadgeBar extends React.Component {
  containerClasses() {
    let classes = "target-overlay-status-badge-bar__badge-container";
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
      prerequisite_locked: "fa fa-lock",
      milestone_locked: "fa fa-lock",
      level_locked: "fa fa-eye"
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

  statusHintString() {
    return {
      passed: "Passed on " + this.submissionDate(),
      failed: "Consider feedback and try re-submitting!",
      submitted: "Submitted on " + this.submissionDate(),
      pending: "Follow completion instructions and submit!",
      level_locked: "You are yet to reach this level",
      milestone_locked: "Complete milestones in previous level first",
      prerequisite_locked: "Complete the prerequisites first"
    }[this.props.target.status];
  }

  submissionDate() {
    return moment(this.props.target.submitted_at).format("MMM D");
  }

  statusContents() {
    return (
      <div className="target-overlay-status-badge-bar__badge-content">
        <span className="target-overlay-status-badge-bar__badge-icon">
          <i className={this.statusIconClasses()} />
        </span>

        <span>{this.statusString()}</span>
      </div>
    );
  }

  render() {
    return (
      <div className={this.containerClasses()}>
        {this.statusContents()}
        <div className="target-overlay-status-badge-bar__info-block">
          <p className="target-overlay-status-badge-bar__hint font-regular">
            {this.statusHintString()}
          </p>
        </div>
      </div>
    );
  }
}

StatusBadgeBar.propTypes = {
  target: PropTypes.object
};
