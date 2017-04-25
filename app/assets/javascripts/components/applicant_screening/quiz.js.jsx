class ApplicantScreeningQuiz extends React.Component {
  constructor(props) {
    super(props);
    this.state = {quizPassed: null};
    this.resultCB = this.resultCB.bind(this);
  }

  resultCB(result) {
    this.setState({quizPassed: result});
  }

  containerClasses() {
    let classes = "applicant-screening__quiz";
    classes += ' ' + this.props.type + '-question';
    return classes;
  }

  render() {
    return (
      <div className={ this.containerClasses() }>
        {this.state.quizPassed === null &&
        <ApplicantScreeningQuestionSection type={ this.props.type } resultCB={ this.resultCB }/>
        }

        { this.state.quizPassed !== null &&
        <ApplicantScreeningQuizResult passed={ this.state.quizPassed } resetCB={ this.props.resetCB }
          type={ this.props.type } formAuthenticityToken={ this.props.formAuthenticityToken }/>
        }
      </div>
    );
  }
}

ApplicantScreeningQuiz.propTypes = {
  type: React.PropTypes.string,
  resetCB: React.PropTypes.func,
  formAuthenticityToken: React.PropTypes.string
};
