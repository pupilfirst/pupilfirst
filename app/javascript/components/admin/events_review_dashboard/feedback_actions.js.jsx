class EventsReviewDashboardFeedbackActions extends React.Component {
  constructor(props) {
    super(props);

    this.sendEmailFeedback = this.sendEmailFeedback.bind(this);
    this.sendSlackFeedback = this.sendSlackFeedback.bind(this);

    this.state = {
      emailSent: false,
      slackSent: false,
      sending: false
    }
  }

  sendSlackFeedback(event) {
    let that = this;
    let postUrl = '/admin/timeline_events/' + this.props.eventId + '/send_slack_feedback';

    this.setState({sending: true});

    $.post({
      url: postUrl,
      data: {feedback_id: that.props.feedbackId, founder_id: that.props.founderId}
    }).done(function () {
      new PNotify({
        title: 'Slack message(s) sent!',
        text: 'Your feedback for event was sent via Slack.'
      });

      that.setState({slackSent: true});
    }).fail(function () {
      alert('Failed to send message via Slack.');
    }).always(function () {
      that.setState({sending: false});
    });
  }

  sendEmailFeedback() {
    let that = this;
    let postUrl = '/admin/timeline_events/' + this.props.eventId + '/send_email_feedback';

    this.setState({sending: true});

    $.post({
      url: postUrl,
      data: {feedback_id: that.props.feedbackId, founder_id: that.props.founderId}
    }).done(function () {
      new PNotify({
        title: 'Email(s) sent!',
        text: 'Your feedback for event was sent via email.'
      });

      that.setState({emailSent: true});
    }).fail(function () {
      alert('Failed to send feedback as email.');
    }).always(function () {
      that.setState({sending: false});
    });
  }

  render() {
    return (
      <div>
        <i className="fa fa-check-square-o"/>&nbsp;
        <span>New Feedback Recorded.&nbsp;</span>
        { this.state.sending &&
        <span>Sending...</span>
        }

        { !this.props.levelZero && !this.state.slackSent && !this.state.sending &&
        <a className="cursor-pointer" onClick={ this.sendSlackFeedback }>
          <i className="fa fa-slack"/> Send feedback via Slack.
        </a>
        }

        { this.state.slackSent &&
        <span>
          <i className="fa fa-slack"/> Slack sent!
        </span>
        }

        &nbsp;
        { !this.state.emailSent && !this.state.sending &&
        <a className="cursor-pointer" onClick={ this.sendEmailFeedback }>
          <i className="fa fa-envelope-o"/> Send feedback via email.
        </a>
        }

        { this.state.emailSent &&
        <span>
          <i className="fa fa-envelope-o"/> Email sent!
        </span>
        }
      </div>
    );
  }
}

EventsReviewDashboardFeedbackActions.propTypes = {
  feedbackId: PropTypes.number,
  founderId: PropTypes.number,
  eventId: PropTypes.number,
  levelZero: PropTypes.bool
};
