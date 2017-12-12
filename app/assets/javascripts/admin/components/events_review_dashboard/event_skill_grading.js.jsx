class EventsReviewDashboardEventSkillGrading extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      grades: {},
      gradingMissing: false,
      undoReviewInProgress: false
    };

    this.radioInputId = this.radioInputId.bind(this);
    this.radioInputName = this.radioInputName.bind(this);
    this.saveReview = this.saveReview.bind(this);
    this.undoReview = this.undoReview.bind(this);
    this.alreadyReviewed = this.alreadyReviewed.bind(this);
    this.undoButtonClasses = this.undoButtonClasses.bind(this);
    this.undoButtonText = this.undoButtonText.bind(this);
    this.enableSaveReviewButton = this.enableSaveReviewButton.bind(this);
    this.changeGrade = this.changeGrade.bind(this);
    this.updateReviewedFlag = this.updateReviewedFlag.bind(this);
  }

  radioInputId(name, skillId) {
    return name + '-' + this.props.eventId + '-' + skillId;
  }

  radioInputName(name, skillId) {
    return 'event-' + this.props.eventId + '-' + skillId + '-' + name;
  }

  changeGrade(event) {
    let gradesClone = _.cloneDeep(this.state.grades);
    const skillId = event.target.getAttribute('data-skillId');
    gradesClone[skillId] = event.target.value;
    this.setState({grades: gradesClone});
  }

  saveReview(event) {
    https://facebook.github.io/react/docs/events.html#event-pooling
    event.persist();

    // clear all error messages
    this.setState({gradingMissing: false});

    if (!this.state.grades) {
      this.setState({gradingMissing: true});
    }
    else {
      console.log('Saving Review...');
      this.setState({gradingMissing: false});
      let eventId = this.props.eventId;
      let status = 'verified';
      let grades = this.state.grades;
      let postUrl = '/admin/timeline_events/' + eventId + '/quick_review';
      const that = this;

      $.post({
        url: postUrl,
        data: {status: status, skill_grades: grades},
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

  alreadyReviewed() {
    return (this.props.rootState.reviewData[this.props.eventId].reviewed === true);
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

  enableSaveReviewButton() {
    // enable 'Save Review' button only when all skills are graded
    const savedGradesCount = Object.keys(this.state.grades).length;
    const rubricGradesCount = Object.keys(this.props.rubric).length;

    return savedGradesCount === rubricGradesCount;
  }

  updateReviewedFlag(flag) {
    const reviewDataClone = _.cloneDeep(this.props.rootState.reviewData);
    reviewDataClone[this.props.eventId].reviewed = flag;
    this.props.setRootState({reviewData: reviewDataClone});
  }

  render(){
    return(<div>
        <strong>Grade for each skill:</strong>
        <br/>
        <table>
          <thead>
          <tr>
            <th>
              Skill
            </th>
            <th>
              Good
            </th>
            <th>
              Great
            </th>
            <th>
              Wow
            </th>
          </tr>
          </thead>
          <tbody>
          { Object.keys(this.props.rubric).map(function (skillId) {
            return (<tr key={skillId}>
              <td> { this.props.rubric[skillId]['name'] } </td>
              <td> <input type='radio' id={this.radioInputId('good', skillId) } value='good' data-skillId={ skillId } name={ this.radioInputName('grade', skillId) }
                          onChange={this.changeGrade}/> </td>
              <td> <input type='radio' id={this.radioInputId('great', skillId) } value='great' data-skillId={ skillId } name={ this.radioInputName('grade', skillId) }
                          onChange={this.changeGrade}/> </td>
              <td> <input type='radio' id={this.radioInputId('wow', skillId) } value='wow' data-skillId={ skillId } name={ this.radioInputName('grade', skillId) }
                          onChange={this.changeGrade}/> </td>
            </tr>)}, this
          )}
          </tbody>
        </table>

        { this.enableSaveReviewButton() &&  <div>
          {!this.alreadyReviewed() && <div>
            <a className='button cursor-pointer margin-bottom-10' onClick={this.saveReview}>Save Review</a>
            {this.state.gradingMissing &&
            <div style={{color: 'red'}}>Specify grade!</div>
            }
          </div>
          }

          {this.alreadyReviewed() && <div>
            <a className="button disabled margin-bottom-10">Save Review</a>
            <a className={ this.undoButtonClasses() } onClick={this.undoReview}>{ this.undoButtonText() }</a>
          </div>
          }
        </div>
        }

      </div>
    )
  }
}

EventsReviewDashboardEventSkillGrading.propTypes = {
  rootState: PropTypes.object,
  setRootState: PropTypes.func,
  eventId: PropTypes.string,
  targetId: PropTypes.string,
  rubric: PropTypes.object
};
