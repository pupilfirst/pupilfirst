class FounderDashboardTargetOverlay extends React.Component  {
  constructor(props) {
    super(props);
    this.state = _.merge({...props.target}, {founderStatuses: null, latestEvent: null, latestFeedback: null});

    this.updateDetails = this.updateDetails.bind(this);
  }

  componentDidMount() {
    {/*let targetOverlayModal = $('.target-overlay__modal');

    targetOverlayModal.modal({
      show: true,
      keyboard: false,
      backdrop: 'static'
    });*/}

    let that = this;
    $.ajax({
      url: '/targets/' + that.props.target.id + '/details',
      success: that.updateDetails
    });
  }

  updateDetails(response) {
    this.setState({
      founderStatuses: response.founderStatuses,
      latestEvent: response.latestEvent,
      latestFeedback: response.latestFeedback
    });
  }

  render() {
    return(
      <div className="target-overlay__modal p-a-0">
        <div className="target-overlay__modal-dialog">
          <div className="target-overlay__modal-content">
            <div className="target-overlay-wrapper m-x-auto p-x-1 p-t-3">
              <div className="target-overlay-container clearfix">
                <div className="target-overlay-header clearfix">
                  {/*<h5 className="modal-title">Details of target {this.state.id}:</h5>*/}
                  <FounderDashboardTargetHeaderTitle target={ this.props.target }/>
                  <FounderDashboardTargetStatusBadge target={ this.props.target }/>
                  <button type="button" className="close" data-dismiss="modal" aria-label="Close" onClick={ this.props.closeCB }>
                    <span aria-hidden="true">&times;</span>
                  </button>
                </div>
                <div className="clearfix">
                  <div className="col-md-8">
                    <FounderDashboardTargetDescription target={ this.props.target }/>
                  </div>
                  <div className="col-md-4">

                  </div>
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
  closeCB: React.PropTypes.func
};
