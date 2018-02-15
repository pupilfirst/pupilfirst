import React from "react";
import PropTypes from "prop-types";
import starsForScore from "../shared/starsForScore";

export default class StatusBadgeBar extends React.Component {
  containerClasses() {
    let classes = "target-overlay-status-badge-bar__badge-container";
    let statusClass = this.props.target.status.replace("_", "-");
    classes += " " + statusClass;
    return classes;
  }

  statusIconClasses() {
    return {
      complete: "fa fa-thumbs-o-up",
      needs_improvement: "fa fa-line-chart",
      submitted: "fa fa-hourglass-half",
      pending: "fa fa-clock-o",
      unavailable: "fa fa-lock",
      not_accepted: "fa fa-thumbs-o-down"
    }[this.props.target.status];
  }

  statusString() {
    return {
      complete: "Completed",
      needs_improvement: "Needs Improvement",
      submitted: "Submitted",
      pending: "Pending",
      unavailable: "Locked",
      not_accepted: "Not Accepted"
    }[this.props.target.status];
  }

  statusHintString() {
    return {
      complete: "Completed on " + this.submissionDate(),
      needs_improvement: "Consider feedback and try re-submitting!",
      submitted: "Submitted on " + this.submissionDate(),
      pending: "Follow completion instructions and submit!",
      unavailable: this.lockedTargetHintString(),
      not_accepted: "Re-submit based on feedback!"
    }[this.props.target.status];
  }

  submissionDate() {
    return moment(this.props.target.submitted_at).format("MMM D");
  }

  lockedTargetHintString() {
    if (this.props.target.submittability === "not_submittable") {
      return "The target is currently unavailable to complete!";
    } else {
      return "Complete prerequisites first!";
    }
  }

  statusContents() {
    let grade = ["good", "great", "wow"].indexOf(this.props.target.grade) + 1;
    const score = parseFloat(this.props.target.score);

    if (this.props.target.status !== "complete" || grade === 0) {
      return (
        <div className="target-overlay-status-badge-bar__badge-content">
          <span className="target-overlay-status-badge-bar__badge-icon">
            <i className={this.statusIconClasses()} />
          </span>

          <span>{this.statusString()}</span>
        </div>
      );
    } else {
      const stars = starsForScore(score, this.props.target.id);

      let gradeString =
        this.props.target.grade.charAt(0).toUpperCase() +
        this.props.target.grade.slice(1);

      return (
        <div className="target-overlay-status-badge-bar__badge-content">
          {stars} {gradeString}!
        </div>
      );
    }
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
