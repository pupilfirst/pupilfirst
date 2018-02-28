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
  }

  componentDidMount() {
    let that = this;
    $.ajax({
      url: "/targets/" + that.props.target.id + "/details",
      success: that.updateDetails
    });

    document.body.classList.add("scroll-lock");
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
    return this.props.target.submittability === "not_submittable";
  }

  singleSubmissionComplete() {
    return (
      this.props.target.submittability === "submittable_once" &&
      !this.isPending()
    );
  }

  submissionBlocked() {
    return ["unavailable", "submitted"].indexOf(this.props.target.status) != -1;
  }

  isPending() {
    return this.props.target.status === "pending";
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
                target={this.props.target}
                hasSingleFounder={this.props.hasSingleFounder}
              />
              <div className="d-none d-md-block">
                {this.isSubmittable() && (
                  <SubmitButton
                    target={this.props.target}
                    openTimelineBuilderCB={this.props.openTimelineBuilderCB}
                  />
                )}
              </div>
            </div>
            <div className="target-overlay__status-badge-block">
              <StatusBadgeBar target={this.props.target} />
            </div>
            <div className="target-overlay__content-wrapper clearfix">
              <div className="col-md-8 target-overlay__content-leftbar">
                <ContentBlock
                  rootProps={this.props.rootProps}
                  iconPaths={this.props.iconPaths}
                  target={this.props.target}
                  linkedResources={this.state.linkedResources}
                />
              </div>
              <div className="col-md-4 target-overlay__content-rightbar">
                <FacultyBlock
                  rootProps={this.props.rootProps}
                  target={this.props.target}
                />

                {this.state.latestEvent && (
                  <TimelineEventPanel
                    event={this.state.latestEvent}
                    feedback={this.state.latestFeedback}
                  />
                )}

                {this.props.target.role === "founder" &&
                  !this.props.hasSingleFounder && (
                    <div className="mt-2">
                      <h5 className="target-overaly__status-title font-semibold">
                        Completion Status:
                      </h5>
                      <FounderStatusPanel
                        founderDetails={this.props.founderDetails}
                        founderStatuses={this.state.founderStatuses}
                        targetId={this.props.target.id}
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
                target={this.props.target}
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
  target: PropTypes.object,
  openTimelineBuilderCB: PropTypes.func,
  founderDetails: PropTypes.array,
  closeCB: PropTypes.func,
  iconPaths: PropTypes.object,
  hasSingleFounder: PropTypes.bool
};
