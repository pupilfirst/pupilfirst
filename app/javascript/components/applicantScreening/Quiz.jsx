import React from "react";
import PropTypes from "prop-types";
import QuizResult from "./QuizResult";
import QuestionSection from "./QuestionSection";

export default class Quiz extends React.Component {
  constructor(props) {
    super(props);
    this.state = { quizPassed: null, githubURL: "" };
    this.resultCB = this.resultCB.bind(this);
    this.githubURLCB = this.githubURLCB.bind(this);
  }

  resultCB(result) {
    this.setState({ quizPassed: result });
  }

  githubURLCB(URL) {
    this.setState({ githubURL: URL });
  }

  containerClasses() {
    let classes = "applicant-screening__quiz";
    classes += " " + this.props.type + "-question";
    return classes;
  }

  render() {
    return (
      <div className={this.containerClasses()}>
        {this.state.quizPassed === null && (
          <QuestionSection
            type={this.props.type}
            resultCB={this.resultCB}
            githubURLCB={this.githubURLCB}
          />
        )}

        {this.state.quizPassed !== null && (
          <QuizResult
            passed={this.state.quizPassed}
            resetCB={this.props.resetCB}
            type={this.props.type}
            formAuthenticityToken={this.props.formAuthenticityToken}
            githubURL={this.state.githubURL}
          />
        )}
      </div>
    );
  }
}

Quiz.propTypes = {
  type: PropTypes.string,
  resetCB: PropTypes.func,
  formAuthenticityToken: PropTypes.string
};
