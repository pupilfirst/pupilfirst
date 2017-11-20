class EventsReviewDashboardEventStatusUpdate extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      status: null,
      grade: null,
      points: '',
      statusMissing: false,
      gradingMissing: false,
      undoReviewInProgress: false
    };

    this.statusChange = this.statusChange.bind(this);
    this.gradeChange = this.gradeChange.bind(this);
    this.pointsChange = this.pointsChange.bind(this);
    this.saveReview = this.saveReview.bind(this);
    this.radioInputId = this.radioInputId.bind(this);
    this.radioInputName = this.radioInputName.bind(this);
    this.undoReview = this.undoReview.bind(this);
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
    // https://facebook.github.io/react/docs/events.html#event-pooling
    event.persist();

    // clear all error messages
    this.setState({statusMissing: false, gradingMissing: false});

    if (!this.state.status) {
      this.setState({statusMissing: true});
    } else if (this.state.status === 'verified' && (!this.state.grade && !this.state.points)) {
      this.setState({gradingMissing: true});
    }
    else {
      console.log('Saving Review...');
      this.setState({statusMissing: false, gradingMissing: false});
      let eventId = this.props.eventId;
      let status = this.state.status;
      let grade = this.state.grade;
      let points = this.state.points;
      let postUrl = '/admin/timeline_events/' + eventId + '/quick_review';
      const that = this;

      $.post({
        url: postUrl,
        data: {status: status, grade: grade, points: points},
        success: function () {
          console.log('Event was successfully marked ' + status);
          new PNotify({
            title: 'Event Reviewed',
            text: 'Event ' + eventId + ' marked ' + status
          });

          that.updateReviewedFlag(true);
        },
        beforeSend: function () {
          event.target.innerHTML = 'Recording Review...'
        },
        error: function (response) {
          let error = (response.responseJSON && response.responseJSON.error) ? response.responseJSON.error : 'Something went wrong at the server. Try again';
          alert(error);
          if (response.status === 422) {
            location.reload();
          } else {
            event.target.innerHTML = 'Save Review'
          }
        }
      });
    }
  }

  radioInputId(name) {
    return name + '-' + this.props.eventId;
  }

  radioInputName(name) {
    return 'event-' + this.props.eventId + '-' + name;
  }

  alreadyReviewed() {
    return (this.props.rootState.reviewData[this.props.eventId].reviewed === true);
  }

  undoReview() {
    if (this.state.undoReviewInProgress) {
      return
    }

    console.log("Undoing the review...");

    const eventId = this.props.eventId;
    const undoUrl = '/admin/timeline_events/' + eventId + '/undo_review';
    const that = this;

    this.setState({undoReviewInProgress: true}, function () {
      $.post({
        url: undoUrl,
        success: function () {
          console.log('Event was successfully undo-d');

          new PNotify({
            title: 'Undo complete',
            text: 'Event ' + eventId + ' marked pending.'
          });

          that.updateReviewedFlag(false);
        },
        error: function (response) {
          const error = (response.responseJSON && response.responseJSON.error) ? response.responseJSON.error : 'Something went wrong at the server. Try again.';

          alert(error);
        }
      }).always(function () {
        that.setState({undoReviewInProgress: false});
      });
    });
  }

  updateReviewedFlag(flag) {
    const reviewDataClone = _.cloneDeep(this.props.rootState.reviewData);
    reviewDataClone[this.props.eventId].reviewed = flag;
    this.props.setRootState({reviewData: reviewDataClone});
  }

  undoButtonClasses() {
    const classes = "button cursor-pointer";

    if (this.state.undoReviewInProgress) {
      return classes + " disabled";
    } else {
      return classes;
    }
  }

  undoButtonText() {
    return this.state.undoReviewInProgress ? 'Undoing...' : 'Undo'
  }

  render() {
    return (
      <div className="margin-bottom-10">
        <strong>Status:</strong>
        <br/>
        <label htmlFor={ this.radioInputId('verified') }>
          <input type='radio' id={ this.radioInputId('verified') } value='verified'
                 name={ this.radioInputName('status') }
                 onChange={ this.statusChange }/>&nbsp;Verified&nbsp;
        </label>
        <label htmlFor={ this.radioInputId('needs_improvement') }>
          <input type='radio' id={ this.radioInputId('needs_improvement') } value='needs_improvement'
                 name={ this.radioInputName('status') }
                 onChange={ this.statusChange }/>&nbsp;Needs Improvement&nbsp;
        </label>
        <label htmlFor={ this.radioInputId('not_accepted') }>
          <input type='radio' id={ this.radioInputId('not_accepted') } value='not_accepted'
                 name={ this.radioInputName('status') }
                 onChange={ this.statusChange }/>&nbsp;Not Accepted&nbsp;
        </label>
        <br/>

        { this.state.status === 'verified' &&
        <div>
          <br/>
          { this.props.targetId &&
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


        {!this.alreadyReviewed() && <div>
          <a className='button cursor-pointer' onClick={this.saveReview}>Save Review</a>
          {this.state.statusMissing &&
          <div style={{color: 'red'}}>Select a status first!</div>
          }
          {this.state.gradingMissing &&
          <div style={{color: 'red'}}>Specify grade or point!</div>
          }
        </div>
        }

        {this.alreadyReviewed() && <div>
          <a className="button disabled">Save Review</a>
          <a className={ this.undoButtonClasses() } onClick={this.undoReview}>{ this.undoButtonText() }</a>
        </div>
        }
      </div>
    )
  }
}

EventsReviewDashboardEventStatusUpdate.propTypes = {
  rootState: React.PropTypes.object,
  setRootState: React.PropTypes.func,
  eventId: React.PropTypes.string,
  targetId: React.PropTypes.string,
};
