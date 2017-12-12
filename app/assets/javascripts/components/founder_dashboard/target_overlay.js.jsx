class FounderDashboardTargetOverlay extends React.Component {
  constructor(props) {
    super(props);
    this.state = _.merge(
      { ...props.target },
      { latestEvent: null, latestFeedback: null, linkedResources: null }
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

  faculty() {
    let faculty_target_relation = "Assigned by:";

    if (_.isString(this.props.target.session_at)) {
      faculty_target_relation = "Session by:";
    }

    return (
      <h5 className="target-overlay__faculty-name m-0">
        <span className="target-overlay__faculty-name-headline">
          {faculty_target_relation}
        </span>

        <span className="font-regular">{this.props.target.faculty.name}</span>
      </h5>
    );
  }

  updateDetails(response) {
    this.setState({
      latestEvent: response.latestEvent,
      latestFeedback: response.latestFeedback,
      linkedResources: response.linkedResources
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
            <div className="target-overlay__header clearfix">
              <TargetOverlayHeaderTitle
                iconPaths={this.props.iconPaths}
                target={this.props.target}
              />
              <div className="d-none d-md-block">
                {this.isSubmittable() && (
                  <TargetOverlaySubmitButton
                    target={this.props.target}
                    openTimelineBuilderCB={this.props.openTimelineBuilderCB}
                  />
                )}
              </div>
            </div>
            <div className="target-overlay__status-badge-block">
              <TargetOverlayStatusBadgeBar target={this.props.target} />
            </div>
            <div className="target-overlay__content-wrapper clearfix">
              <div className="col-md-8 target-overlay__content-leftbar">
                <TargetOverlayContentBlock
                  iconPaths={this.props.iconPaths}
                  target={this.props.target}
                  linkedResources={this.state.linkedResources}
                />
              </div>
              <div className="col-md-4 target-overlay__content-rightbar">
                <div className="target-overlay__faculty-box">
                  <span className="target-overlay__faculty-avatar mr-2">
                    <img
                      className="img-fluid"
                      src={this.props.target.faculty.image_url}
                    />
                  </span>
                  {this.faculty()}
                </div>
                {this.state.latestEvent && (
                  <TargetOverlayTimelineEventPanel
                    event={this.state.latestEvent}
                    feedback={this.state.latestFeedback}
                  />
                )}

                {this.props.target.role === "founder" && (
                  <div className="mt-2">
                    <h5 className="target-overaly__status-title font-semibold">
                      Completion Status:
                    </h5>
                    <TargetOverlayFounderStatusPanel
                      founderDetails={this.props.founderDetails}
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
              <TargetOverlaySubmitButton
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

FounderDashboardTargetOverlay.propTypes = {
  target: PropTypes.object,
  openTimelineBuilderCB: PropTypes.func,
  founderDetails: PropTypes.array,
  closeCB: PropTypes.func,
  iconPaths: PropTypes.object
};
