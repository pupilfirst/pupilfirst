class TargetOverlayTimelineEventPanel extends React.Component {
  constructor(props) {
    super(props);
    this.slackButton = this.slackButton.bind(this);
  }

  slackButton() {
    if(this.props.feedback.facultySlackUsername) {
      return(
        <a className="btn btn-with-icon btn-md btn-primary text-uppercase m-t-1 discuss-on-slack__button"
           href={'https://svlabs-public.slack.com/messages/@' + this.props.feedback.facultySlackUsername} target="_blank">
          <i className="fa fa-slack" aria-hidden="true"/>
          <span>Discuss On Slack</span>
        </a>
      );
    } else {
      return null;
    }
  }

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
                Day { this.props.event.days_elapsed }
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
            { this.props.feedback &&
            <div className="target-overlay-timeline-submission__feedback m-t-1">
              <div className="target-overlay-timeline-submission__commenter-box">
                <img className="target-overlay-timeline-submission__commenter-avatar" src={ this.props.feedback.facultyImageUrl }/>
                <h6 className="assigner-name m-a-0">
                  Feedback by&nbsp;
                  <div className="font-regular">{ this.props.feedback.facultyName }</div>
                </h6>
              </div>
              <p className="font-light" dangerouslySetInnerHTML={ {__html: this.props.feedback.feedback} }/>
              { this.slackButton() }
            </div>
            }
          </div>
        </div>
      </div>
    );
  }
}

TargetOverlayTimelineEventPanel.propTypes = {
  event: React.PropTypes.object,
  feedback: React.PropTypes.object
}
