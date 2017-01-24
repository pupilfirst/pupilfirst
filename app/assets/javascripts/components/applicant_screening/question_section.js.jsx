class ApplicantScreeningQuestionSection extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      questionNumber: 1,
      selectedAnswers: {
        1: null,
        2: null,
        3: null
      }
    };

    this.handleNext = this.handleNext.bind(this);
    this.selectAnswerCB = this.selectAnswerCB.bind(this);
  }

  selectAnswerCB(answer) {
    let updatedAnswers = $.extend({}, this.state.selectedAnswers);
    updatedAnswers[this.state.questionNumber] = answer;
    this.setState({selectedAnswers: updatedAnswers});
  }

  answerOptionKey(answer) {
    return this.props.type + "-question-" + this.state.questionNumber + "-" + answer;
  }

  handleNext() {
    if (this.state.questionNumber < 3) {
      this.setState({questionNumber: this.state.questionNumber + 1})
    } else {
      this.props.resultCB(this.hasPassed());
    }
  }

  hasPassed() {
    return this.state.selectedAnswers[1] == 'Yes' || this.state.selectedAnswers[2] == 'Yes' || this.state.selectedAnswers[3] == 'Yes';
  }

  isHintVisible() {
    return this.state.selectedAnswers[this.state.questionNumber] !== null;
  }

  isAnswerCorrect() {
    return this.state.selectedAnswers[this.state.questionNumber] === 'Yes';
  }

  render() {
    return (
      <div className="applicant-screening__question-section">
        <div className="applicant-screening__question-number m-b-2 font-semibold">{ this.state.questionNumber }</div>
        <ApplicantScreeningQuestion type={ this.props.type } questionNumber={ this.state.questionNumber }/>

        <div className="applicant-screening__answer-options p-t-1 p-b-2">
          <ApplicantScreeningAnswerOption key={ this.answerOptionKey('yes') } text="Yes"
            selectAnswerCB={ this.selectAnswerCB }/>
          <ApplicantScreeningAnswerOption key={ this.answerOptionKey('no') } text="No"
            selectAnswerCB={ this.selectAnswerCB }/>
        </div>

        { this.isHintVisible() &&
        <div className="applicant-screening__answer-hint m-t-2">
          <ApplicantScreeningAnswerHint correctAnswer={ this.isAnswerCorrect() } type={ this.props.type }
            questionNumber={ this.state.questionNumber }/>

          <button className="btn btn-with-icon btn-primary btn-md text-uppercase" onClick={ this.handleNext }>
            <i className="fa fa-arrow-right"/> Next
          </button>
        </div>
        }
      </div>
    );
  }
}

ApplicantScreeningQuestionSection.propTypes = {
  type: React.PropTypes.string,
  resultCB: React.PropTypes.func
};
