class EventsReviewDashboardEventFeedback extends React.Component {

  constructor(props) {
    super(props);
    this.state = {
      feedback: '',
      showFeedbackForm: false,
      feedbackMissing: false,
      feedbackRecorded: false,
    };

    this.eventFeedbackFormId = this.eventFeedbackFormId.bind(this);
    this.feedbackChange = this.feedbackChange.bind(this);
    this.saveFeedback = this.saveFeedback.bind(this);
    this.toggleFeedbackForm = this.toggleFeedbackForm.bind(this);
    this.markFeedbackRecorded = this.markFeedbackRecorded.bind(this);
  }

  eventFeedbackFormId () {
    return 'event-feedback-form-' + this.props.eventId;
  }

  feedbackChange (value) {
    this.setState({feedback: value, feedbackMissing: false});
  }

  markFeedbackRecorded () {
    this.setState({feedbackRecorded: true})
  }

  saveFeedback (event) {
    this.setState({feedbackMissing: false});
    if (!this.state.feedback) {
      this.setState({feedbackMissing: true});
    } else {
      console.log('Saving Feedback');
      let eventId = this.props.eventId;
      let feedback = this.state.feedback;
      let toggleFeedbackForm = this.toggleFeedbackForm;
      let markFeedbackRecorded = this.markFeedbackRecorded;
      let postUrl = '/admin/timeline_events/' + eventId + '/save_feedback';
      $.post({
        url: postUrl,
        data: {feedback: feedback},
        success: function () {
          console.log('Feedback Saved!');
          new PNotify({
            title: 'Feedback Saved!',
            text: 'Your feedback for event ' + eventId + ' was saved successfully'
          });
          markFeedbackRecorded();
          toggleFeedbackForm();
        },
        beforeSend: function () {
          event.target.innerHTML = 'Saving Feedback...'
        },
        error: function () {
          alert('Failed to save your feedback. Try again')
        }
      });
    }
  }

  toggleFeedbackForm () {
    this.setState({showFeedbackForm: !this.state.showFeedbackForm})
  }

  render() {
    return (
      <div className="margin-bottom-10">
        { !this.state.showFeedbackForm &&
        <div>
          { this.state.feedbackRecorded &&
          <div>
            <i className="fa fa-check-square-o"/>&nbsp;
            <span>New Feedback Recorded</span>
          </div>
          }
          { !this.state.feedbackRecorded &&
          <div>
            <i className="fa fa-comment-o"/>&nbsp;
            <a className="cursor-pointer" onClick={ this.toggleFeedbackForm }>
              Add Feedback
            </a>
          </div>
          }
        </div>
        }

        { this.state.showFeedbackForm &&
        <div>
          <EventsReviewDashboardTrixEditor onChange={ this.feedbackChange } value={ this.state.feedback }/>
          <br/>
          <a className='button cursor-pointer' onClick={ this.saveFeedback }>Save Feedback</a>
          <a className='button cursor-pointer' onClick={ this.toggleFeedbackForm }>Close</a>
          { this.state.feedbackMissing &&
          <div style={{color: 'red'}}>Enter a feedback first!</div>
          }
        </div>
        }
      </div> )
  }
};
