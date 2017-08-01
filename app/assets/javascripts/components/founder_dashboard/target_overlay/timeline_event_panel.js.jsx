class TargetOverlayTimelineEventPanel extends React.Component {
  constructor(props) {
    super(props);
    this.slackButton = this.slackButton.bind(this);
  }

  slackButton() {
    if(this.props.feedback.facultySlackUsername) {
      return(
        <a className="btn btn-with-icon btn-sm btn-primary m-t-1 discuss-on-slack__button"
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
      <div className="target-overlay-timeline-submission__container p-b-1 m-t-1">
        <p className="target-overlay-timeline-submission__title font-semibold">Latest Timeline Submission:</p>
        <div className="target-overlay-timeline-submission__box">
          <div className="target-overlay-timeline-submission__header p-a-1">
            <div className="target-overlay-timeline-submission__header-date-box m-r-1">
              <span className="target-overlay-timeline-submission__header-date text-uppercase font-semibold">{ moment(this.props.event.event_on).format('MMM') }</span>
              <span className="target-overlay-timeline-submission__header-date--large font-semibold">{ moment(this.props.event.event_on).date() }/{ moment(this.props.event.event_on).format('YY') }</span>
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
              <a className="target-overlay__link target-overlay__link--attachment" target='_blank' href="">
                <span className="target-overlay__link-icon">
                  <i className="fa fa-file-image-o"/>
                </span>
                <span className="target-overlay__link-text target-overlay__link--attachment-text">Cover Image</span>
              </a>
              <a className="target-overlay__link target-overlay__link--attachment" target='_blank' href="">
                <span className="target-overlay__link-icon">
                  <i className="fa fa-link"/>
                </span>
                <span className="target-overlay__link-text target-overlay__link--attachment-text">External</span>
              </a>
              <a className="target-overlay__link target-overlay__link--attachment" target='_blank' href="">
                <span className="target-overlay__link-icon">
                  <i className="fa fa-file-text-o"/>
                </span>
                <span className="target-overlay__link-text target-overlay__link--attachment-text">Keynote Presentation</span>
              </a>

            </div>
            { this.props.feedback &&
            <div className="target-overlay-timeline-submission__feedback m-t-1">
              <div className="target-overlay-timeline-submission__commenter-box">
                <span className="target-overlay-timeline-submission__commenter-avatar">
                  <img className="img-fluid" src={ this.props.feedback.facultyImageUrl }/>
                </span>
                <h6 className="target-overlay-timeline-submission__commenter-name m-a-0">
                  <span className="target-overlay-timeline-submission__commenter--small">Feedback by:</span>
                  <span className="font-regular">{ this.props.feedback.facultyName }</span>
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
