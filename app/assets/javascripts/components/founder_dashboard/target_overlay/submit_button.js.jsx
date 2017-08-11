class TargetOverlaySubmitButton extends React.Component {
  constructor(props) {
    super(props);
    this.openTimelineBuilder = this.openTimelineBuilder.bind(this);
  }

  openTimelineBuilder() {
    this.props.openTimelineBuilderCB(this.props.target.id, this.props.target.timeline_event_type_id);
  }

  submitButtonText() {
    if (!this.props.target.link_to_complete) {
      return this.isPending() ? 'Submit' : 'Re-Submit';
    } else {
      return this.isPending() ? 'Complete' : 'Update';
    }
  }

  isPending() {
    return (this.props.target.status === 'pending');
  }

  render() {
    return (
      <div className="pull-xs-right">
        { this.props.target.link_to_complete &&
          <a href={ this.props.target.link_to_complete }
                  className="btn btn-with-icon btn-md btn-secondary text-uppercase btn-timeline-builder js-founder-dashboard__trigger-builder js-founder-dashboard__action-bar-add-event-button">
            <i className="fa fa-upload" aria-hidden="true"/>
            <span>{ this.submitButtonText() }</span>
          </a>
        }
        { !this.props.target.link_to_complete &&
          <button onClick={ this.openTimelineBuilder }
                  className="btn btn-with-icon btn-md btn-secondary text-uppercase btn-timeline-builder js-founder-dashboard__trigger-builder js-founder-dashboard__action-bar-add-event-button">
            <i className="fa fa-upload" aria-hidden="true"/>
            <span>{ this.submitButtonText() }</span>
          </button>
        }
      </div>
    )
  }
}

TargetOverlaySubmitButton.propTypes = {
  target: React.PropTypes.object,
  openTimelineBuilderCB: React.PropTypes.func
};
