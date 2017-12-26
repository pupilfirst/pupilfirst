import React from "react";
import PropTypes from "prop-types";
import AnswerHint from "./AnswerHint";
import AnswerOption from "./AnswerOption";
import Question from "./Question";

export default class QuestionSection extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      questionNumber: 1,
      selectedAnswers: {
        1: null,
        2: null,
        3: null
      },
      hasGithubError: false
    };

    this.handleNext = this.handleNext.bind(this);
    this.selectAnswerCB = this.selectAnswerCB.bind(this);
  }

  selectAnswerCB(answer) {
    let updatedAnswers = $.extend({}, this.state.selectedAnswers);
    updatedAnswers[this.state.questionNumber] = answer;
    this.setState({ selectedAnswers: updatedAnswers });
  }

  answerOptionKey(answer) {
    return (
      this.props.type + "-question-" + this.state.questionNumber + "-" + answer
    );
  }

  handleNext() {
    // check Github URL validity, if applicable
    let githubPresent =
      this.state.questionNumber === 4 && $("#github-url").val().length > 0;
    if (githubPresent && !/github|bitbucket/.test($("#github-url").val())) {
      this.setState({ hasGithubError: true });
    } else {
      let questionsCount = this.props.type === "coder" ? 4 : 3;

      if (githubPresent) {
        this.props.githubURLCB($("#github-url").val());
      }

      if (this.state.questionNumber < questionsCount) {
        this.setState({ questionNumber: this.state.questionNumber + 1 });
      } else {
        this.props.resultCB(this.hasPassed());
      }
    }
  }

  hasPassed() {
    return (
      this.state.selectedAnswers[1] == "Yes" ||
      this.state.selectedAnswers[2] == "Yes" ||
      this.state.selectedAnswers[3] == "Yes" ||
      ($("#github-url").length > 0 && $("#github-url").val().length > 0)
    );
  }

  isHintVisible() {
    return this.state.selectedAnswers[this.state.questionNumber] !== null;
  }

  isAnswerCorrect() {
    return this.state.selectedAnswers[this.state.questionNumber] === "Yes";
  }

  gitHubFormGroupClasses() {
    return this.state.hasGithubError ? "form-group has-danger" : "form-group";
  }

  render() {
    return (
      <div className="applicant-screening__question-section">
        <div className="applicant-screening__question-number mb-3 font-semibold">
          {this.state.questionNumber}
        </div>
        <Question
          type={this.props.type}
          questionNumber={this.state.questionNumber}
        />

        {/*handle a special fourth question for Github link*/}
        {this.state.questionNumber === 4 && (
          <div className="applicant-screening__answer-options pt-2 pb-3">
            <div className={this.gitHubFormGroupClasses()}>
              <input
                name="github-url"
                type="text"
                className="form-control form-control-danger"
                id="github-url"
                placeholder="https://github.com/your-profile"
              />
              {this.state.hasGithubError && (
                <div className="form-control-feedback">
                  Not a valid Github/Bitbucket URL
                </div>
              )}
              <small className="form-text text-muted">
                Leave empty to skip.
              </small>
            </div>
          </div>
        )}

        {this.state.questionNumber < 4 && (
          <div className="applicant-screening__answer-options pt-2 pb-3">
            <AnswerOption
              key={this.answerOptionKey("yes")}
              text="Yes"
              selectAnswerCB={this.selectAnswerCB}
            />
            <AnswerOption
              key={this.answerOptionKey("no")}
              text="No"
              selectAnswerCB={this.selectAnswerCB}
            />
          </div>
        )}

        {this.isHintVisible() && (
          <div className="applicant-screening__answer-hint mt-3">
            {/*Question 4 does not have a hint*/}
            {this.state.questionNumber !== 4 && (
              <AnswerHint
                correctAnswer={this.isAnswerCorrect()}
                type={this.props.type}
                questionNumber={this.state.questionNumber}
              />
            )}

            <button
              className="btn btn-with-icon btn-primary btn-md text-uppercase"
              onClick={this.handleNext}
            >
              <i className="fa fa-arrow-right" /> Next
            </button>
          </div>
        )}
      </div>
    );
  }
}

QuestionSection.propTypes = {
  type: PropTypes.string,
  resultCB: PropTypes.func,
  githubURLCB: PropTypes.func
};
