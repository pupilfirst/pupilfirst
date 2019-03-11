import React from "react";
import PropTypes from "prop-types";
import ContentBlock from "./targetOverlay/ContentBlock";
import FounderStatusPanel from "./targetOverlay/FounderStatusPanel";
import HeaderTitle from "./targetOverlay/HeaderTitle";
import StatusBadgeBar from "./targetOverlay/StatusBadgeBar";
import SubmitButton from "./targetOverlay/SubmitButton";
import TimelineEventPanel from "./targetOverlay/TimelineEventPanel";
import FacultyBlock from "./targetOverlay/FacultyBlock";
import { jsComponent as QuizComponent } from "../../components/Quiz__Root.bs";

export default class TargetOverlay extends React.Component {
  constructor(props) {
    super(props);
    this.state = _.merge(
      { ...props.target },
      {
        latestEvent: null,
        latestFeedback: null,
        linkedResources: null,
        pendingFounderIds: [],
        grades: null,
        quizQuestions: null,
        showQuiz: false
      }
    );

    this.updateDetails = this.updateDetails.bind(this);
    this.openTimelineBuilder = this.openTimelineBuilder.bind(this);
    this.completeTarget = this.completeTarget.bind(this);
    this.getFaculty = this.getFaculty.bind(this);
    this.getTarget = this.getTarget.bind(this);
    this.autoVerify = this.autoVerify.bind(this);
    this.invertShowQuiz = this.invertShowQuiz.bind(this);
  }

  componentDidMount() {
    this.reloadDetails();
    document.body.classList.add("scroll-lock");
  }

  getTarget() {
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
    return (
      !this.props.courseEnded &&
      (this.isPending() || this.isReSubmittable() || this.state.showQuiz)
    );
  }

  isReSubmittable() {
    return this.getTarget().resubmittable && this.resubmissionAllowed();
  }

  resubmissionAllowed() {
    let target = this.getTarget();
    return (
      !target.auto_verified && ["passed", "failed"].includes(target.status)
    );
  }

  isPending() {
    return this.getTarget().status === "pending";
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

    updatedTargets[targetIndex].status = "passed";
    updatedTargets[targetIndex].submitted_at = new moment();
    const that = this;
    this.props.setRootState({ targets: updatedTargets }, () => {
      that.reloadDetails();
    });
  }

  autoVerify(target) {
    const autoVerifyEndpoint =
      "/targets/" + this.props.targetId + "/auto_verify";

    fetch(autoVerifyEndpoint, {
      method: "POST",
      credentials: "include",
      body: JSON.stringify({
        authenticity_token: this.props.rootProps.authenticityToken
      }),
      headers: {
        "content-type": "application/json"
      }
    }).then(response => {
      if (response.ok) {
        const hasLinkToComplete =
          _.isString(target.link_to_complete) &&
          target.link_to_complete.length > 0;

        const [title, text] = hasLinkToComplete
          ? ["Redirecting...", "Redirecting you to the link now..."]
          : ["Done!", "This target has been marked as complete."];

        new PNotify({
          title: title,
          text: text,
          type: "success"
        });

        this.completeTarget();
        this.state.showQuiz && this.invertShowQuiz();

        if (hasLinkToComplete) {
          // Take user to the link where zhe has to be sent.
          window.setTimeout(() => {
            window.location = target.link_to_complete;
          }, 1000);
        }
      } else {
        new PNotify({
          title: "Something went wrong!",
          text: "Please try again.",
          type: "error"
        });
      }
    });
  }

  invertShowQuiz() {
    this.setState(prevState => ({ showQuiz: !prevState.showQuiz }));
  }

  updateDetails(response) {
    this.setState({
      latestEvent: response.latestEvent,
      latestFeedback: response.latestFeedback,
      linkedResources: response.linkedResources,
      pendingFounderIds: response.pendingFounderIds,
      grades: response.grades,
      quizQuestions: response.quizQuestions
    });
  }

  getFaculty(target) {
    const targetFaculty = target.faculty;

    if (_.isObject(targetFaculty)) {
      return _.find(this.props.rootProps.faculty, faculty => {
        return faculty.id === targetFaculty.id;
      });
    }
  }

  render() {
    const target = this.getTarget();
    const faculty = this.getFaculty(target);
    return (
      <div className="target-overlay__overlay">
        <div className="target-overlay__container mx-auto">
          {this.props.courseEnded && (
            <div className="target-overlay__course-locked-notice">
              The course has ended and submissions are disabled for all targets!
            </div>
          )}
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
                target={target}
                hasSingleFounder={this.props.hasSingleFounder}
              />
            </div>

            {this.state.showQuiz ? (
              <QuizComponent
                quizQuestions={this.state.quizQuestions}
                submitTargetCB={this.autoVerify}
              />
            ) : (
              <div className="target-overlay__content-wrapper clearfix">
                <div className="col-md-8 target-overlay__content-leftbar">
                  <ContentBlock
                    rootProps={this.props.rootProps}
                    iconPaths={this.props.iconPaths}
                    target={target}
                    linkedResources={this.state.linkedResources}
                  />
                </div>
                <div className="col-md-4 target-overlay__content-rightbar px-0">
                  <div className="target-overlay__status-badge-block">
                    <StatusBadgeBar
                      rootProps={this.props.rootProps}
                      completeTargetCB={this.completeTarget}
                      target={target}
                      openTimelineBuilderCB={this.props.openTimelineBuilderCB}
                      autoVerifyCB={this.autoVerify}
                      invertShowQuizCB={this.invertShowQuiz}
                      isSubmittable={this.isSubmittable()}
                      overlayLoaded={this.state.quizQuestions !== null}
                    />
                  </div>

                  {_.isObject(faculty) && <FacultyBlock faculty={faculty} />}

                  {this.state.latestEvent && (
                    <TimelineEventPanel
                      event={this.state.latestEvent}
                      feedback={this.state.latestFeedback}
                    />
                  )}

                  <FounderStatusPanel
                    founderDetails={this.props.founderDetails}
                    pendingFounderIds={this.state.pendingFounderIds}
                    targetId={this.targetId}
                  />
                </div>
              </div>
            )}
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
            {this.isSubmittable(target) && (
              <SubmitButton
                rootProps={this.props.rootProps}
                completeTargetCB={this.completeTarget}
                target={target}
                openTimelineBuilderCB={this.props.openTimelineBuilderCB}
                autoVerifyCB={this.autoVerify}
                invertShowQuizCB={this.invertShowQuiz}
                overlayLoaded={this.state.quizQuestions !== null}
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
  targetId: PropTypes.number.isRequired,
  openTimelineBuilderCB: PropTypes.func,
  founderDetails: PropTypes.array,
  closeCB: PropTypes.func,
  iconPaths: PropTypes.object,
  hasSingleFounder: PropTypes.bool,
  courseEnded: PropTypes.bool
};
