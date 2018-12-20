import React from "react";
import PropTypes from "prop-types";
import SubmitButton from "./SubmitButton";

export default class StatusBadgeBar extends React.Component {
  statusClass() {
    return this.props.target.status.replace("_", "-");
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
      <div
        className={
          "target-overlay-status-badge-bar__badge-content d-flex justify-content-between align-items-center " +
          this.statusClass()
        }
      >
        <div className="target-overlay-status-badge-bar__badge-status">
          <span className="target-overlay-status-badge-bar__badge-icon">
            <i className={this.statusIconClasses()} />
          </span>
          <span>{this.statusString()}</span>
        </div>

        <div className="d-none d-md-block">
          {this.props.isSubmittable && (
            <SubmitButton
              rootProps={this.props.rootProps}
              completeTargetCB={this.props.completeTargetCB}
              target={this.props.target}
              openTimelineBuilderCB={this.props.openTimelineBuilderCB}
              autoVerifyCB={this.props.autoVerifyCB}
              invertShowQuizCB={this.props.invertShowQuizCB}
              overlayLoaded={this.props.overlayLoaded}
            />
          )}
        </div>
      </div>
    );
  }

  gradesList() {
    let grades = this.props.target.grades;
    let criteriaNames = this.props.rootProps.criteriaNames;
    let gradeLabels = this.props.rootProps.gradeLabels;
    return (
      <div className="target-overlay-status-badge-bar__grades-container p-4">
        <div className="target-overlay-status-badge-bar__grades-header">
          Grades received:
        </div>
        <ul className="target-overlay-status-badge-bar__grades-list list-unstyled">
          {Object.keys(grades).map(criterionId => {
            return (
              <li key={criterionId}>
                {criteriaNames[criterionId]}: {gradeLabels[grades[criterionId]]}
                <div
                  className="btn-group btn-group-toggle d-flex"
                  data-toggle="buttons"
                >
                  <label className="btn btn-secondary disabled">
                    <input
                      type="radio"
                      name="options"
                      id="option1"
                      autocomplete="off"
                      checked
                    />
                    1
                  </label>
                  <label className="btn btn-secondary disabled">
                    <input
                      type="radio"
                      name="options"
                      id="option2"
                      autocomplete="off"
                    />
                    2
                  </label>
                  <label className="btn btn-secondary disabled">
                    <input
                      type="radio"
                      name="options"
                      id="option3"
                      autocomplete="off"
                    />
                    3
                  </label>
                </div>
              </li>
            );
          })}
        </ul>
      </div>
    );
  }

  render() {
    return (
      <div className="target-overlay-status-badge-bar__badge-container">
        {this.statusContents()}
        <div className="target-overlay-status-badge-bar__info-block">
          <p className="target-overlay-status-badge-bar__hint font-regular">
            {this.statusHintString()}
          </p>
        </div>
        {this.props.target.grades && this.gradesList()}
      </div>
    );
  }
}

StatusBadgeBar.propTypes = {
  target: PropTypes.object,
  rootProps: PropTypes.object,
  completeTargetCB: PropTypes.func,
  openTimlineBuilderCB: PropTypes.func,
  isSubmittable: PropTypes.bool,
  autoVerifyCB: PropTypes.func.isRequired,
  invertShowQuizCB: PropTypes.func.isRequired
};
