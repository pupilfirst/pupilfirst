import React from "react";

export default class CoderFailed extends React.Component {
  render() {
    return (
      <p className="applicant-screening__quiz-result-text mb-3">
        <span className="font-semibold">
          You have not cleared our basic screening process.
        </span>
        This course might not be a right fit for you. But, we encourage you to
        build your skills in the programming space and restart your process.
        Thank you.
      </p>
    );
  }
}
