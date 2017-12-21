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

  statusContents() {
    let grade = ["good", "great", "wow"].indexOf(this.props.target.grade) + 1;
    let score = parseFloat(this.props.target.score);

    if (this.props.target.status != "complete" || grade === 0) {
      return (
        <span>
          <span className="founder-dashboard-target-header__status-badge-icon">
            <i className={this.statusIconClasses()} />
          </span>

          <span>{this.statusString()}</span>
        </span>
      );
    } else {
      let stars = _.times(Math.floor(score)).map(function(e, i) {
        return (
          <i
            key={"filled-star-" + this.props.target.id + "-" + i}
            className="fa fa-star founder-dashboard-target-header__status-badge-star"
          />
        );
      }, this);

      if (score % 1 === 0.5) {
        const halfStar = (
          <i
            key={"half-star-" + this.props.target.id}
            className="fa fa-star-half-o founder-dashboard-target-header__status-badge-star"
          />
        );
        stars = stars.concat([halfStar]);
      }

      const emptyStars = _.times(3 - Math.ceil(score));

      const emptyStarArray = emptyStars.map(function(e, i) {
        return (
          <i
            key={"empty-star-" + this.props.target.id + "-" + i}
            className="fa fa-star-o founder-dashboard-target-header__status-badge-star"
          />
        );
      }, this);

      stars = stars.concat(emptyStarArray);

      let gradeString =
        this.props.target.grade.charAt(0).toUpperCase() +
        this.props.target.grade.slice(1);

      return (
        <span>
          {stars}

          <span>&nbsp;{gradeString}!</span>
        </span>
      );
    }
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
