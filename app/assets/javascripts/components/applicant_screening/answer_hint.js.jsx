class ApplicantScreeningAnswerHint extends React.Component {
  coderHint() {
    switch (this.props.questionNumber) {
      case 1:
        if (this.props.correctAnswer) {
          return "Great! Engineers who regularly contribute to open source do well in our program.";
        } else {
          return "This isn&rsquo;t a complete red flag, but if you haven&rsquo;t, contributing to open source might be a good way to get a lot of prerequisite skills for our program (like collaborating with a team, fundamentals of version control and issue tracking, and of course, writing great code).";
        }
      case 2:
        if (this.props.correctAnswer) {
          return "Great stuff! We&rsquo;ve noticed that engineers who have commitment to other online courses generally do well in our program.";
        } else {
          return "Our program is a paid six-month course that requires at least 10 hours of commitment a week. Successful founders are committed to their startup journey.";
        }
      case 3:
        if (this.props.correctAnswer) {
          return "Great stuff! Our program requires that your team has a great coder who has already built apps and / or websites, so you&rsquo;re on the right track.";
        } else {
          return "If you haven&rsquo;t built real apps or websites, this might not be the right program to join. Building both a real startup and learning to code in six months is very difficult.";
        }
      default:
        console.error(
          "Unexpected question number for hint: " + this.props.questionNumber
        );
        return null;
    }
  }

  nonCoderHint() {
    switch (this.props.questionNumber) {
      case 1:
        if (this.props.correctAnswer) {
          return "Great! Students who work with developers tend to take the product role. The teams in our program require a product role which might be a right fit for you.";
        } else {
          return "If you haven&rsquo;t worked with developers prior to this then this might not be the right program to join. Building a software startup requires basic interest towards building a product.";
        }
      case 2:
        if (this.props.correctAnswer) {
          return "Amazing! We value the effort you put in to make money early in life. It seems that you have keen interest in building a business. Welcome to the club!";
        } else {
          return "This isn&rsquo;t a complete red flag, but the the making money is an essential skill that&rsquo;ll come in handy during the program. It helps you understand the art of convincing people, selling, and creating value that people will pay for.";
        }
      case 3:
        if (this.props.correctAnswer) {
          return "Super! We&rsquo;re looking for candidates who have held leadership positions and you seem to fit the bill.";
        } else {
          return "Bummer! Applicants with some form of leadership experience tend to perform well in our program. As a team lead at SV.CO, you are expected to lead your team in the six-month journey.";
        }
      default:
        console.error(
          "Unexpected question number for hint: " + this.props.questionNumber
        );
        return null;
    }
  }

  hint() {
    if (this.props.type === "coder") {
      return { __html: this.coderHint() };
    } else if (this.props.type === "non-coder") {
      return { __html: this.nonCoderHint() };
    } else {
      console.error("Unexpected type: " + this.props.type);
      return null;
    }
  }

  render() {
    return (
      <p
        className="applicant-screening__answer-hint-text mb-3"
        dangerouslySetInnerHTML={this.hint()}
      />
    );
  }
}

ApplicantScreeningAnswerHint.propTypes = {
  type: PropTypes.string,
  questionNumber: PropTypes.number,
  correctAnswer: PropTypes.bool
};
