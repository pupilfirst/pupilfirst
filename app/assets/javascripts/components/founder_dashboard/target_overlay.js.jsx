class FounderDashboardTargetOverlay extends React.Component  {
  constructor(props) {
    super(props);
    this.state = _.merge({...props.target}, {founderStatuses: null, latestEvent: null, latestFeedback: null});

    this.updateDetails = this.updateDetails.bind(this);
  }

  componentDidMount() {
    let targetOverlayModal = $('.target-overlay__modal');

    targetOverlayModal.modal({
      show: true,
      keyboard: false,
      backdrop: 'static'
    });

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
      <div className="target-overlay__modal modal fade">
        <div className="target-overlay__modal-dialog modal-dialog" role="document">
          <div className="target-overlay__modal-content modal-content">
            <div className="modal-header">
              <h5 className="modal-title">Details of target {this.state.id}:</h5>
              <button type="button" className="close" data-dismiss="modal" aria-label="Close" onClick={ this.props.closeCB }>
                <span aria-hidden="true">&times;</span>
              </button>
            </div>
            <div className="modal-body">
              <p>TODO</p>
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
