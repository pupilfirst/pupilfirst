import React from "react";
import PropTypes from "prop-types";

export default class TimelineEventPanel extends React.Component {
  constructor(props) {
    super(props);
    this.slackButton = this.slackButton.bind(this);
    this.attachmentLinks = this.attachmentLinks.bind(this);
  }

  slackButton() {
    if (this.props.feedback.facultySlackUsername) {
      return (
        <a
          className="btn btn-with-icon btn-sm btn-primary discuss-on-slack__button"
          href={
            "https://svlabs-public.slack.com/messages/@" +
            this.props.feedback.facultySlackUsername
          }
          target="_blank"
        >
          <i className="fa fa-slack" aria-hidden="true" />
          <span>Discuss On Slack</span>
        </a>
      );
    } else {
      return null;
    }
  }

  attachmentLinks() {
    return this.props.event.attachments.map(function(attachment) {
      faClasses =
        attachment.type === "file" ? "fa fa-file-text-o" : "fa fa-link";
      return (
        <a
          className="target-overlay__link target-overlay__link--attachment"
          target="_blank"
          href={attachment.url}
          key={attachment.url}
        >
          <span className="target-overlay__link-icon">
            <i className={faClasses} />
          </span>
          <span className="target-overlay__link-text target-overlay__link--attachment-text">
            {attachment.title}
          </span>
        </a>
      );
    });
  }

  render() {
    return (
      <div className="target-overlay-timeline-event-panel__container pb-3 mt-3">
        <h6 className="target-overlay-timeline-event-panel__title font-semibold pl-1">
          Latest Timeline Submission:
        </h6>
        <div className="target-overlay-timeline-event-panel__box">
          <div className="d-flex target-overlay-timeline-event-panel__header p-3">
            <div className="target-overlay-timeline-event-panel__header-date-box mr-2">
              <span className="target-overlay-timeline-event-panel__header-date text-uppercase font-semibold">
                {moment(this.props.event.event_on).format("MMM")}
              </span>
              <span className="target-overlay-timeline-event-panel__header-date--large font-semibold">
                {moment(this.props.event.event_on).date()}/{moment(
                  this.props.event.event_on
                ).format("YY")}
              </span>
            </div>
            <div className="target-overlay-timeline-event-panel__header-title pt-1">
              <h6 className="font-semibold brand-secondary mb-0">
                {this.props.event.title}
              </h6>
              <p className="target-overlay-timeline-event-panel__header-title-date">
                Day {this.props.event.days_elapsed}
              </p>
            </div>
          </div>
          <div className="target-overlay-timeline-event-panel__content">
            <p className="px-3">{this.props.event.description}</p>
            {!_.isEmpty(this.props.event.attachments) && (
              <div className="target-overlay-timeline-event-panel__content-attachments px-3 pt-3">
                <h6 className="font-semibold">Attachments</h6>
                {this.attachmentLinks()}
              </div>
            )}
          </div>
        </div>
        {this.props.feedback && (
          <div className="target-overlay-timeline-event-panel__feedback mt-3">
            <div className="target-overlay-timeline-event-panel__commenter-box p-3">
              <span className="target-overlay-timeline-event-panel__commenter-avatar">
                <img
                  className="img-fluid"
                  src={this.props.feedback.facultyImageUrl}
                />
              </span>
              <h6 className="target-overlay-timeline-event-panel__commenter-name m-0">
                <span className="target-overlay-timeline-event-panel__commenter-label">
                  Feedback by:
                </span>
                <span className="font-regular">
                  {this.props.feedback.facultyName}
                </span>
              </h6>
            </div>
            <p
              className="px-3 pt-3"
              dangerouslySetInnerHTML={{ __html: this.props.feedback.feedback }}
            />
            <div className="p-3">{this.slackButton()}</div>
          </div>
        )}
      </div>
    );
  }
}

TimelineEventPanel.propTypes = {
  event: PropTypes.object,
  feedback: PropTypes.object
};
