import React from "react";
import PropTypes from "prop-types";

export default class SubmitButton extends React.Component {
  constructor(props) {
    super(props);

    this.handleSubmit = this.handleSubmit.bind(this);
  }

  submitLabel() {
    switch (this.submissionState()) {
      case "pending":
        return "Submit";
      case "ongoing":
        return this.props.submissionProgress + "%";
      case "processing":
        return "Wait";
      case "done":
        return "Done";
      case "error":
        return "Error";
      default:
        return "";
    }
  }

  submissionState() {
    if (this.props.submissionSuccessful) {
      return "done";
    } else if (
      this.props.submissionError === "5XX" ||
      this.props.submissionError === "other"
    ) {
      return "error";
    } else if (this.props.submissionProgress == 100) {
      return "processing";
    } else if (this.props.submissionProgress != null) {
      return "ongoing";
    } else {
      return "pending";
    }
  }

  handleSubmit(event) {
    event.preventDefault();

    if (this.props.submissionProgress == null) {
      this.props.submitCB();
    }
  }

  submitDisabled() {
    return this.submissionState() != "pending";
  }

  buttonClasses() {
    let classes =
      "btn btn-with-icon text-uppercase js-timeline-builder__submit-button";

    if (
      _.isString(this.props.submissionError) &&
      this.props.submissionError !== "offline"
    ) {
      return classes + " btn-danger";
    } else {
      return classes + " btn-primary";
    }
  }

  iconClasses() {
    switch (this.submissionState()) {
      case "ongoing":
        return "fa fa-cog fa-spin";
      case "processing":
        return "fa fa-circle-o-notch fa-spin";
      case "done":
        return "fa fa-check";
      case "error":
        return "fa fa-exclamation-triangle";
      default:
        return null;
    }
  }

  errorContent() {
    switch (this.props.submissionError) {
      case "5XX":
        return "Oops! Something went wrong. The SV.CO team has been notified of this error. Please reload the page and try again, or contact us on Slack to speed us up!";
      case "offline":
        return "You are not connected to the internet. Please check your internet connection and try again.";
      default:
        return "An unexpected error has occurred. Please refresh your page and try again. If this persists, please reach out to the SV.CO team for help.";
    }
  }

  errorTitle() {
    switch (this.props.submissionError) {
      case "offline":
        return "You're Offline";
      default:
        return "Unexpected Error";
    }
  }

  render() {
    return (
      <div className="timeline-builder__submit-container timeline-builder__select-section-tab">
        <button
          type="submit"
          disabled={this.submitDisabled()}
          className={this.buttonClasses()}
          onClick={this.handleSubmit}
          data-title={this.errorTitle()}
          data-content={this.errorContent()}
          data-placement="bottom"
          data-trigger="manual"
        >
          {this.iconClasses() && <i className={this.iconClasses()} />}
          {this.submitLabel()}
        </button>
      </div>
    );
  }
}

SubmitButton.propTypes = {
  submissionProgress: PropTypes.number,
  submitCB: PropTypes.func,
  submissionError: PropTypes.string,
  submissionSuccessful: PropTypes.bool
};
