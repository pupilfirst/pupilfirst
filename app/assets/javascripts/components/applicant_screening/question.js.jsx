class ApplicantScreeningQuestion extends React.Component {
  coderQuestion() {
    switch (this.props.questionNumber) {
      case(1):
        return "Have you contributed to Open Source?";
      case(2):
        return "Have you <em>completed</em> a technical course at Coursera, Udacity or other MOOCs?";
      case(3):
        return "Have you built websites and/or apps?";
      default:
        console.error("Unexpected question number: " + this.props.questionNumber);
        return null;
    }
  }

  nonCoderQuestion() {
    switch (this.props.questionNumber) {
      case(1):
        return "Have you ever worked with a developer to design website/apps?";
      case(2):
        return "Have you ever made money while in college?";
      case(3):
        return "Have you ever led a team that organised college fests or any other events?";
      default:
        console.error("Unexpected question number: " + this.props.questionNumber);
        return null;
    }
  }

  question() {
    if (this.props.type === 'coder') {
      return {__html: this.coderQuestion()};
    } else if (this.props.type === 'non-coder') {
      return {__html: this.nonCoderQuestion()};
    } else {
      console.error('Unexpected type: ' + this.props.type);
      return null;
    }
  }

  render() {
    return (
      <h3 className="applicant-screening__question font-semibold" dangerouslySetInnerHTML={ this.question() }>
      </h3>
    )
  }
}

ApplicantScreeningQuestion
  .propTypes = {
  type: React.PropTypes.string,
  questionNumber: React.PropTypes.number
};
