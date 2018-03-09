import React from "react";
import PropTypes from "prop-types";
import ContentBlock from "./targetOverlay/ContentBlock";
import FounderStatusPanel from "./targetOverlay/FounderStatusPanel";
import HeaderTitle from "./targetOverlay/HeaderTitle";
import StatusBadgeBar from "./targetOverlay/StatusBadgeBar";
import SubmitButton from "./targetOverlay/SubmitButton";
import TimelineEventPanel from "./targetOverlay/TimelineEventPanel";
import FacultyBlock from "./targetOverlay/FacultyBlock";

export default class TargetOverlay extends React.Component {
  constructor(props) {
    super(props);
    this.state = _.merge(
      { ...props.target },
      {
        latestEvent: null,
        latestFeedback: null,
        linkedResources: null,
        founderStatuses: null
      }
    );

    this.updateDetails = this.updateDetails.bind(this);
    this.openTimelineBuilder = this.openTimelineBuilder.bind(this);
    this.completeTarget = this.completeTarget.bind(this);
  }

  componentDidMount() {
    this.reloadDetails();
    document.body.classList.add("scroll-lock");
  }

  target() {
    return _.find(this.props.rootState.targets, ["id", this.props.targetId]);
  }

  reloadDetails() {
    let that = this;

    $.ajax({
      url: "/targets/" + that.props.targetId + "/details",
      success: that.updateDetails
    });
  }

  componentWillUnmount() {
    document.body.classList.remove("scroll-lock");
  }

  isSubmittable() {
    return !(
      this.isNotSubmittable() ||
      this.singleSubmissionComplete() ||
      this.submissionBlocked()
    );
  }

  isNotSubmittable() {
    return this.target().submittability === "not_submittable";
  }

  singleSubmissionComplete() {
    return (
      ["submittable_once", "auto_verify"].includes(
        this.target().submittability
      ) && !this.isPending()
    );
  }

  submissionBlocked() {
    return ["unavailable", "submitted"].includes(this.target().status);
  }

  isPending() {
    return this.target().status === "pending";
  }

  openTimelineBuilder() {
    if (this.props.currentLevel == 0) {
      $(".js-founder-dashboard__action-bar-add-event-button").popover("show");

      setTimeout(function() {
        $(".js-founder-dashboard__action-bar-add-event-button").popover("hide");
      }, 3000);
    } else {
      this.props.openTimelineBuilderCB();
    }
  }

  completeTarget() {
    const updatedTargets = _.cloneDeep(this.props.rootState.targets);

    const targetIndex = _.findIndex(updatedTargets, [
      "id",
      this.props.targetId
    ]);

    updatedTargets[targetIndex].status = "complete";
    const that = this;
    this.props.setRootState({ targets: updatedTargets }, () => {
      that.reloadDetails();
    });
  }

  updateDetails(response) {
    this.setState({
      latestEvent: response.latestEvent,
      latestFeedback: response.latestFeedback,
      linkedResources: response.linkedResources,
      founderStatuses: response.founderStatuses
    });
  }

  render() {
    return (
      <div className="target-overlay__overlay">
        <div className="target-overlay__container mx-auto">
          <div className="target-overlay__body clearfix">
            <button
              type="button"
              className="target-overlay__overlay-close d-none d-md-flex"
              aria-label="Close"
              onClick={this.props.closeCB}
            >
              <img
                className="target-overlay__overlay-close-icon"
                src={this.props.iconPaths.backButton}
              />
              <span className="target-overlay__overlay-close-text">Back</span>
            </button>
            <div className="target-overlay__header d-flex align-items-center justify-content-between">
              <HeaderTitle
                iconPaths={this.props.iconPaths}
                target={this.target()}
                hasSingleFounder={this.props.hasSingleFounder}
              />
              <div className="d-none d-md-block">
                {this.isSubmittable() && (
                  <SubmitButton
                    rootProps={this.props.rootProps}
                    completeTargetCB={this.completeTarget}
                    target={this.target()}
                    openTimelineBuilderCB={this.props.openTimelineBuilderCB}
                  />
                )}
              </div>
            </div>
            <div className="target-overlay__status-badge-block">
              <StatusBadgeBar target={this.target()} />
            </div>
            <div className="target-overlay__content-wrapper clearfix">
              <div className="col-md-8 target-overlay__content-leftbar">
                <ContentBlock
                  rootProps={this.props.rootProps}
                  iconPaths={this.props.iconPaths}
                  target={this.target()}
                  linkedResources={this.state.linkedResources}
                />
              </div>
              <div className="col-md-4 target-overlay__content-rightbar">
                <FacultyBlock
                  rootProps={this.props.rootProps}
                  target={this.target()}
                />

                {this.state.latestEvent && (
                  <TimelineEventPanel
                    event={this.state.latestEvent}
                    feedback={this.state.latestFeedback}
                  />
                )}

                {this.target().role === "founder" &&
                  !this.props.hasSingleFounder && (
                    <div className="mt-2">
                      <h5 className="target-overaly__status-title font-semibold">
                        Completion Status:
                      </h5>
                      <FounderStatusPanel
                        founderDetails={this.props.founderDetails}
                        founderStatuses={this.state.founderStatuses}
                        targetId={this.targetId}
                      />
                    </div>
                  )}
              </div>
            </div>
          </div>
        </div>
        <div className="target-overlay__mobile-fixed-navbar d-block d-md-none">
          <button
            type="button"
            className="target-overlay__mobile-back-button pull-left"
            aria-label="Close"
            onClick={this.props.closeCB}
          >
            <img
              className="target-overlay__mobile-back-button-icon"
              src={this.props.iconPaths.backButton}
            />
            <span className="target-overlay__mobile-back-button-text">
              Back
            </span>
          </button>
          <div className="target-overlay__mobile-submit-button-container pull-right pr-3">
            {this.isSubmittable() && (
              <SubmitButton
                rootProps={this.props.rootProps}
                completeTargetCB={this.completeTarget}
                target={this.target()}
                openTimelineBuilderCB={this.props.openTimelineBuilderCB}
              />
            )}
          </div>
        </div>
      </div>
    );
  }
}

TargetOverlay.propTypes = {
  rootProps: PropTypes.object.isRequired,
  rootState: PropTypes.object.isRequired,
  setRootState: PropTypes.func.isRequired,
  target: PropTypes.object,
  openTimelineBuilderCB: PropTypes.func,
  founderDetails: PropTypes.array,
  closeCB: PropTypes.func,
  iconPaths: PropTypes.object,
  hasSingleFounder: PropTypes.bool
};
