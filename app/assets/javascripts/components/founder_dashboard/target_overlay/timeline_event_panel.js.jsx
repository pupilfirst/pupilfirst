class TargetOverlayTimelineEventPanel extends React.Component {
  render() {
    return(
      <div className="target-overlay-timeline-submission__container p-y-1">
        <p className="target-overlay-timeline-submission__title">Latest Timeline Submission:</p>
        <div className="target-overlay-timeline-submission__box">
          <div className="target-overlay-timeline-submission__header p-a-1">
            <div className="target-overlay-timeline-submission__header-date-box m-r-1">
              <span className="target-overlay-timeline-submission__header-date font-semibold">{ moment(this.props.event.event_on).date() }</span>
              <span className="target-overlay-timeline-submission__header-date--small">{ moment(this.props.event.event_on).format('MMM') }</span>
              <span className="target-overlay-timeline-submission__header-date--small">{ moment(this.props.event.event_on).format('YYYY') }</span>
            </div>
            <div className="target-overlay-timeline-submission__header-title">
              <h5 className="font-semibold brand-secondary m-b-0">
                { this.props.event.title }
              </h5>
              <p className="target-overlay-timeline-submission__header-title-date">
                { this.props.event.days_elapsed_string } Day
              </p>
            </div>
          </div>
          <div className="target-overlay-timeline-submission__content">
            <p className="font-light p-x-1">
              { this.props.event.description }
            </p>
            <div className="target-overlay-timeline-submission__content-attachments m-b-1 p-a-1">
              <h6 className="font-semibold">Attachments</h6>

            </div>
            <div className="target-overlay-timeline-submission__feedback m-t-1">
              <div className="target-overlay-timeline-submission__commenter-box">
                <div className="target-overlay-timeline-submission__commenter-avatar">
                </div>
                <h6 className="assigner-name m-a-0">
                  Feedback by&nbsp;
                  <div className="font-regular">Faculty Name</div>
                </h6>
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
    );
  }
}

TargetOverlayTimelineEventPanel.propTypes = {
  event: React.PropTypes.object
}
