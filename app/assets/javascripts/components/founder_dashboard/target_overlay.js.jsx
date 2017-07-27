class FounderDashboardTargetOverlay extends React.Component  {
  constructor(props) {
    super(props);
    this.state = _.merge({...props.target}, {latestEvent: null, latestFeedback: null});

    this.updateDetails = this.updateDetails.bind(this);
    this.openTimelineBuilder = this.openTimelineBuilder.bind(this);
  }

  openTimelineBuilder() {
    if (this.props.currentLevel == 0){
      $('.js-founder-dashboard__action-bar-add-event-button').popover('show');

      setTimeout(function () {
        $('.js-founder-dashboard__action-bar-add-event-button').popover('hide');
      }, 3000);
    } else {
      this.props.openTimelineBuilderCB();
    }
  }

  componentDidMount() {
    let that = this;
    $.ajax({
      url: '/targets/' + that.props.target.id + '/details',
      success: that.updateDetails
    });
  }

  assigner() {
    if (typeof(this.props.target.assigner) === 'undefined' || this.props.target.assigner === null) {
      return null;
    } else {
      return (
        <h6 className="assigner-name m-a-0">
          Assigned by&nbsp;
          <div className="font-regular">{ this.props.target.assigner.name }</div>
        </h6>
      );
    }
  }

  updateDetails(response) {
    this.setState({
      latestEvent: response.latestEvent,
      latestFeedback: response.latestFeedback
    });
  }

  render() {
    return(
      <div className="target-overlay__overlay">
        <div className="target-overlay__container m-x-auto p-x-1 p-y-3">
          <div className="target-overlay__body clearfix">
            <button type="button" className="close target-overlay__overlay-close" aria-label="Close" onClick={ this.props.closeCB }>
              <span aria-hidden="true">&times;</span>
            </button>
            <div className="target-overlay__header clearfix">
              <TargetOverlayHeaderTitle iconPaths={ this.props.iconPaths } target={ this.props.target }/>
              <TargetOverlayStatusBadge target={ this.props.target }/>
              <div className="pull-xs-right">
                <button onClick={ this.openTimelineBuilder }
                  className="btn btn-with-icon btn-md btn-secondary text-uppercase btn-timeline-builder js-founder-dashboard__trigger-builder hidden-sm-down js-founder-dashboard__action-bar-add-event-button">
                  <i className="fa fa-upload" aria-hidden="true"/>
                  <span>Submit</span>
                </button>
              </div>
            </div>
            <div className="target-overlay-content-wrapper clearfix">
              <div className="col-md-8 target-overlay__leftbar">
                <TargetOverlayContentBlock iconPaths={ this.props.iconPaths } target={ this.props.target } founderDetails={ this.props.founderDetails } />
              </div>
              <div className="col-md-4 target-overlay__rightbar">
                <div className="target-overlay__assigner-box">
                  <div className="target-overlay__assigner-avatar m-r-1">
                  </div>
                  { this.assigner() }
                </div>
                <div className="target-overlay-timeline-submission__container p-y-1">
                  <p className="target-overlay-timeline-submission__title">Latest Timeline Submission:</p>
                  <div className="target-overlay-timeline-submission__box">
                    <div className="target-overlay-timeline-submission__header p-a-1">
                      <div className="target-overlay-timeline-submission__header-date-box m-r-1">
                        <span className="target-overlay-timeline-submission__header-date font-semibold">20</span>
                        <span className="target-overlay-timeline-submission__header-date--small">Jun</span>
                        <span className="target-overlay-timeline-submission__header-date--small">2017</span>
                      </div>
                      <div className="target-overlay-timeline-submission__header-title">
                        <h5 className="font-semibold brand-secondary m-b-0">
                          Attended SV.CO Session
                        </h5>
                        <p className="target-overlay-timeline-submission__header-title-date">
                          April 6, 2017 (139<sup>th</sup> day)
                        </p>
                      </div>
                    </div>
                    <div className="target-overlay-timeline-submission__content">
                      <p className="font-light p-x-1">
                        After watching How to Evaluate Progress: After attending session
                        by Vishnu on evaluating Progress, we have understood the real
                        meaning of progress for the point of view of a startup.
                        Please find the attachment for Nuggets
                      </p>
                      <div className="target-overlay-timeline-submission__content-attachments m-b-1 p-a-1">
                        <h6 className="font-semibold">Attachments</h6>

                      </div>
                      <div className="target-overlay-timeline-submission__feedback m-t-1">
                        <div className="target-overlay-timeline-submission__commenter-box">
                          <div className="target-overlay-timeline-submission__commenter-avatar">
                          </div>
                          { this.assigner() }
                        </div>
                        <p className="font-light">
                          Identify what helps in making you better. Like finding out the specific are that needs improvement
                        </p>
                        <button className="btn btn-with-icon btn-md btn-primary text-uppercase m-t-1 discuss-on-slack__button">
                          <i className="fa fa-slack" aria-hidden="true"/>
                          <span>Discuss On Slack</span>
                        </button>
                      </div>
                    </div>
                  </div>
                </div>

                <div>
                  { this.props.target.role === 'founder' &&
                  <FounderDashboardFounderStatusPanel founderDetails={ this.props.founderDetails }
                    targetId={ this.props.target.id} fetchStatus={this.props.fetchFounderStatuses}/> }
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
}

FounderDashboardTargetOverlay.propTypes = {
  target: React.PropTypes.object,
  openTimelineBuilderCB: React.PropTypes.func,
  founderDetails: React.PropTypes.array,
  fetchFounderStatuses: React.PropTypes.bool,
  closeCB: React.PropTypes.func,
  iconPaths: React.PropTypes.object
};
