class FounderDashboardTargetOverlay extends React.Component  {
  constructor(props) {
    super(props);
    this.state = _.merge({...props.target}, {latestEvent: null, latestFeedback: null});

    this.updateDetails = this.updateDetails.bind(this);
    this.openTimelineBuilder = this.openTimelineBuilder.bind(this);
  }

  componentDidMount() {
    let that = this;
    $.ajax({
      url: '/targets/' + that.props.target.id + '/details',
      success: that.updateDetails
    });
  }

  isSubmittable() {
    return !(this.isNotSubmittable() || this.singleSubmissionComplete() || this.submissionBlocked());
  }

  isNotSubmittable() {
    return this.props.target.submittability === 'not_submittable';
  }

  singleSubmissionComplete() {
    return this.props.target.submittability === 'submittable_once' && !this.isPending();
  }

  submissionBlocked() {
    return ['unavailable', 'submitted'].indexOf(this.props.target.status) != -1;
  }

  isPending() {
    return (this.props.target.status === 'pending');
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

  assigner() {
    return (
      <h6 className="assigner-name m-a-0">
        Assigned by&nbsp;
        <div className="font-regular">{ this.props.target.assigner.name }</div>
      </h6>
    );
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
              <div className="pull-xs-left hidden-sm-down"><FounderDashboardTargetStatusBadge target={ this.props.target }/></div>
              { this.isSubmittable() && <TargetOverlaySubmitButton target={ this.props.target } openTimelineBuilderCB={ this.props.openTimelineBuilderCB }/> }
            </div>
            <div className="target-overlay-content-wrapper clearfix">
              <div className="col-md-8 target-overlay__leftbar">
                <TargetOverlayContentBlock iconPaths={ this.props.iconPaths } target={ this.props.target } />
              </div>
              <div className="col-md-4 target-overlay__rightbar">
                <div className="target-overlay__assigner-box">
                  <span className="target-overlay__assigner-avatar m-r-1">
                    <img className="img-fluid" src={ this.props.target.assigner.image_url } />
                  </span>
                  { this.assigner() }
                </div>
                { this.state.latestEvent && <TargetOverlayTimelineEventPanel event={ this.state.latestEvent } feedback={ this.state.latestFeedback }/>}

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
