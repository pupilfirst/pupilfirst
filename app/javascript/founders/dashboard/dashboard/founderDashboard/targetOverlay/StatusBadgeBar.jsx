import React from "react";
import PropTypes from "prop-types";
import SubmitButton from "./SubmitButton";
const UndoButton = require("./TargetOverlay__UndoButton.bs.js").make;

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
      pending: "Follow instructions to complete this target!",
      level_locked: "You are yet to reach this level",
      milestone_locked: "Complete milestones in previous level first",
      prerequisite_locked: "Complete the prerequisites first"
    }[this.props.target.status];
  }

  gradePillModifierClass(criterionId) {
    let modifierClass =
      this.props.target.grades[criterionId] < this.props.rootProps.passGrade
        ? "target-overlay-grade-bar__grade-pill--failed"
        : "target-overlay-grade-bar__grade-pill--passed";
    return modifierClass;
  }

  submissionDate() {
    return moment(this.props.target.submitted_at).format("MMM D");
  }

  canUndo() {
    return this.props.target.status === "submitted";
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
              completeTargetCB={() => {
                this.props.updateTargetStatusCB("passed");
              }}
              target={this.props.target}
              openTimelineBuilderCB={this.props.openTimelineBuilderCB}
              autoVerifyCB={this.props.autoVerifyCB}
              invertShowQuizCB={this.props.invertShowQuizCB}
              overlayLoaded={this.props.overlayLoaded}
            />
          )}

          {this.canUndo() && (
            <UndoButton
              authenticityToken={this.props.rootProps.authenticityToken}
              undoSubmissionCB={() => {
                this.props.updateTargetStatusCB("pending");
              }}
              targetId={this.props.target.id}
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
    let maxGrade = this.props.rootProps.maxGrade;
    return (
      <div className="btn-toolbar target-overlay-grade-bar__container flex-column pb-4">
        <div className="target-overlay-status-badge-bar__grades-header pb-1 mb-2">
          Grades received:
        </div>
        {Object.keys(grades).map(criterionId => {
          return (
            <div key={criterionId}>
              <div className="target-overlay-grade-bar__header d-flex justify-content-between pb-1">
                <div className="target-overlay-grade-bar__criterion-name">
                  {criteriaNames[criterionId]}
                  <span>
                    :
                    <span className="target-overlay-grade-bar__grade-label">
                      {gradeLabels[grades[criterionId]]}
                    </span>
                  </span>
                </div>
                <div className="target-overlay-grade-bar__grade font-semibold">
                  {grades[criterionId] + "/" + maxGrade}
                </div>
              </div>
              <div
                className="btn-group target-overlay-grade-bar__track d-flex"
                role="group"
              >
                {Object.keys(gradeLabels).map((grade, index) => {
                  let modifierClass =
                    grades[criterionId] >= index + 1
                      ? this.gradePillModifierClass(criterionId)
                      : "";
                  return (
                    <div
                      key={index}
                      className={
                        "target-overlay-grade-bar__grade-pill " + modifierClass
                      }
                      role="button"
                    />
                  );
                })}
              </div>
            </div>
          );
        })}
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
  updateTargetStatusCB: PropTypes.func.isRequired,
  openTimlineBuilderCB: PropTypes.func,
  isSubmittable: PropTypes.bool,
  autoVerifyCB: PropTypes.func.isRequired,
  invertShowQuizCB: PropTypes.func.isRequired
};
