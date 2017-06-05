class FounderDashboardTargetOverlay extends React.Component  {
  componentDidMount() {
    let targetOverlayModal = $('.target-overlay__modal');

    targetOverlayModal.modal({
      show: true,
      keyboard: false,
      backdrop: 'static'
    });
  }

  render() {
    return(
      <div className="target-overlay__modal modal fade">
        <div className="target-overlay__modal-dialog modal-dialog" role="document">
          <div className="target-overlay__modal-content modal-content">
            <div className="modal-header">
              <h5 className="modal-title">Details of target {this.props.target.id}:</h5>
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
