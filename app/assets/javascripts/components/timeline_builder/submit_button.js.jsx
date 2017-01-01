class TimelineBuilderSubmitButton extends React.Component {
  constructor(props) {
    super(props);

    this.handleSubmit = this.handleSubmit.bind(this);
  }

  submitLabel() {
    switch (this.submissionState()) {
      case 'pending':
        return 'Submit';
      case 'ongoing':
        return this.props.submissionProgress + "%";
      case 'processing':
        return 'Wait';
      case 'done':
        return 'Done';
      case 'error':
        return 'Error';
      default:
        return '';
    }
  }

  submissionState() {
    if (this.props.submissionSuccessful) {
      return 'done';
    } else if (this.props.hasSubmissionError) {
      return 'error';
    } else if (this.props.submissionProgress == 100) {
      return 'processing';
    } else if (this.props.submissionProgress != null) {
      return 'ongoing';
    } else {
      return 'pending';
    }
  }

  handleSubmit(event) {
    event.preventDefault();

    if (this.props.submissionProgress == null) {
      this.props.submitCB()
    }
  }

  submitDisabled() {
    return this.submissionState() != 'pending';
  }

  buttonClasses() {
    let classes = "btn btn-with-icon text-xs-uppercase js-timeline-builder__submit-button";

    if (this.props.hasSubmissionError) {
      return classes + ' btn-danger';
    } else {
      return classes + ' btn-primary';
    }
  }

  iconClasses() {
    switch (this.submissionState()) {
      case 'ongoing':
        return 'fa fa-cog fa-spin';
      case 'processing':
        return 'fa fa-circle-o-notch fa-spin';
      case 'done':
        return 'fa fa-check';
      case 'error':
        return 'fa fa-exclamation-triangle';
      default:
        return null;
    }
  }

  render() {
    return (
      <div className="timeline-builder__submit-container timeline-builder__select-section-tab">
        <button type="submit" disabled={ this.submitDisabled() } className={ this.buttonClasses() }
                onClick={ this.handleSubmit } data-title="Unexpected Error"
                data-content="Oops! Something went wrong. The SV.CO team has been notified of this error. Please reload the page and try again, or contact us on Slack to speed us up!"
                data-placement="bottom" data-trigger="manual">
          { this.iconClasses() &&
          <i className={ this.iconClasses() }/>
          }
          { this.submitLabel() }
        </button>
      </div>
    )
  }
}

TimelineBuilderSubmitButton.propTypes = {
  submissionProgress: React.PropTypes.number,
  submitCB: React.PropTypes.func,
  hasSubmissionError: React.PropTypes.bool,
  submissionSuccessful: React.PropTypes.bool,
};
