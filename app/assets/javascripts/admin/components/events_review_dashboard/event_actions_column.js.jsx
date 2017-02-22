class EventsReviewDashboardEventActionsColumn extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      status: null,
      grade: null,
      points: '',
      statusMissing: false,
      gradingMissing: false,
      feedback: '',
      showFeedbackForm: false,
      feedbackMissing: false,
      feedbackRecorded: false,
    };
    this.statusChange = this.statusChange.bind(this);
    this.gradeChange = this.gradeChange.bind(this);
    this.pointsChange = this.pointsChange.bind(this);
    this.saveReview = this.saveReview.bind(this);
    this.radioInputId = this.radioInputId.bind(this);
    this.radioInputName = this.radioInputName.bind(this);
    this.eventFeedbackFormId = this.eventFeedbackFormId.bind(this);
    this.feedbackChange = this.feedbackChange.bind(this);
    this.saveFeedback = this.saveFeedback.bind(this);
    this.toggleFeedbackForm = this.toggleFeedbackForm.bind(this);
    this.markFeedbackRecorded = this.markFeedbackRecorded.bind(this);
  }

  statusChange(event) {
    this.setState({status: event.target.value});
  }

  gradeChange(event) {
    this.setState({grade: event.target.value});
  }

  pointsChange(event) {
    this.setState({points: event.target.value});
  }

  saveReview(event) {
    // clear all error messages
    this.setState({statusMissing: false, gradingMissing: false});

    if ( !this.state.status ) {
      this.setState({statusMissing: true});
    } else if ( this.state.status == 'verified' && (!this.state.grade && !this.state.points) ) {
      this.setState({gradingMissing: true});
    }
    else {
      console.log('Saving Review...');
      this.setState({statusMissing: false, gradingMissing: false});
      let eventId = this.props.eventData['event_id'];
      let status = this.state.status;
      let grade = this.state.grade;
      let points = this.state.points;
      let removeEvent = this.props.removeEventCB;
      let postUrl = '/admin/timeline_events/' + eventId + '/quick_review';
      $.post({
        url: postUrl,
        data: {status: status, grade: grade, points: points},
        success: function () {
          console.log('Event was successfully marked ' + status);
          new PNotify({
            title: 'Event Reviewed',
            text: 'Event ' + eventId + ' marked ' + status
          });
          removeEvent(eventId);
        },
        beforeSend: function () {
          event.target.innerHTML = 'Recording Review...'
        },
        error: function (response) {
          let error = (response.responseJSON && response.responseJSON.error) ? response.responseJSON.error : 'Something went wrong at the server. Try again';
          alert(error);
          location.reload();
        }
      });
    }
  }

  radioInputId(name) {
    return name + '-' + this.props.eventData['event_id'];
  }

  radioInputName(name) {
    return 'event-' + this.props.eventData['event_id'] + '-' + name;
  }

  eventFeedbackFormId () {
    return 'event-feedback-form-' + this.props.eventData['event_id'];
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
      let eventId = this.props.eventData['event_id'];
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

  render () {
    return (
      <div>
        <div>
          <i className="fa fa-eye"/>&nbsp;
          <a data-method="post" href={ this.props.eventData['impersonate_url'] } target='_blank'>
            Preview as Founder
          </a>
        </div><br/>

        <div>
          <i className="fa fa-edit"/>&nbsp;
          <a href={'/admin/timeline_events/' + this.props.eventData['event_id'] + '/edit'} target='_blank'>
            Edit Event
          </a>
        </div><br/>


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

        <br/>
        <div>
          <strong>Status:</strong>
          <br/>
          <label htmlFor={ this.radioInputId('verified') }>
            <input type='radio' id={ this.radioInputId('verified') } value='verified' name={ this.radioInputName('status') }
                   onChange={ this.statusChange }/>&nbsp;Verified&nbsp;
          </label>
          <label htmlFor={ this.radioInputId('needs_improvement') }>
            <input type='radio' id={ this.radioInputId('needs_improvement') } value='needs_improvement' name={ this.radioInputName('status') }
                   onChange={ this.statusChange }/>&nbsp;Needs Improvement&nbsp;
          </label>
          <label htmlFor={ this.radioInputId('not_accepted') }>
            <input type='radio' id={ this.radioInputId('not_accepted') } value='not_accepted' name={ this.radioInputName('status') }
                   onChange={ this.statusChange }/>&nbsp;Not Accepted&nbsp;
          </label>
          <br/>


          { this.state.status == 'verified' &&
          <div>
            <br/>
            { this.props.eventData['target_id'] &&
            <div>
              <strong>Grade:</strong>
              <br/>
              <label htmlFor={ this.radioInputId('wow') }>
                <input type='radio' id={this.radioInputId('wow') } value='wow' name={ this.radioInputName('grade') }
                       onChange={ this.gradeChange }/>&nbsp;Wow&nbsp;
              </label>
              <label htmlFor={ this.radioInputId('great') }>
                <input type='radio' id={ this.radioInputId('great') } value='great' name={ this.radioInputName('grade') }
                       onChange={ this.gradeChange }/>&nbsp;
                Great&nbsp;
              </label>
              <label htmlFor={ this.radioInputId('good') }>
                <input type='radio' id={ this.radioInputId('good') } value='good' name={ this.radioInputName('grade') }
                       onChange={ this.gradeChange }/>&nbsp;
                Good&nbsp;
              </label>
              <br/>
              <span>OR</span><br/>
            </div>
            }


            <strong>Points:</strong><br/>
            <input style={{width: '50px'}} type='number' value={this.state.points} onChange={ this.pointsChange }/>
          </div>
          }
          <br/>


          <a className='button cursor-pointer' onClick={ this.saveReview }>Save Review</a>
          { this.state.statusMissing &&
          <div style={{color: 'red'}}>Select a status first!</div>
          }
          { this.state.gradingMissing &&
          <div style={{color: 'red'}}>Specify grade or point!</div>
          }
        </div>
      </div>
    )
  }
}

EventsReviewDashboardEventActionsColumn.propTypes = {
  eventData: React.PropTypes.object
};
