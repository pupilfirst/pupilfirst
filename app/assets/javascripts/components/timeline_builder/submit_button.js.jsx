class TimelineBuilderSubmitButton extends React.Component {
  constructor(props) {
    super(props);

    this.handleSubmit = this.handleSubmit.bind(this);
  }

  submitLabel() {
    if (this.props.submissionProgress == null) {
      return 'Submit';
    } else if (this.props.submissionProgress == 100) {
      return 'Done';
    } else if (this.props.submissionProgress >= 0) {
      return this.props.submissionProgress + "%";
    } else {
      return '';
    }
  }

  submissionInProgress() {
    return (this.props.submissionProgress != null && !this.submissionDone());
  }

  submissionDone() {
    return this.props.submissionProgress == 100;
  }

  handleSubmit(event) {
    event.preventDefault();

    if (this.props.submissionProgress == null) {
      this.props.submitCB()
    }
  }

  submitDisabled() {
    return (this.submissionInProgress() || this.submissionDone())
  }

  render() {
    return (
      <div className="timeline-builder__submit-btn timeline-builder__select-section-tab">
        <button type="submit" disabled={ this.submitDisabled() }
                className="btn btn-with-icon btn-primary text-xs-uppercase"
                onClick={ this.handleSubmit }>
          { this.submissionInProgress() &&
          <i className="fa fa-cog fa-spin"/>
          }
          { this.submissionDone() &&
          <i className="fa fa-check"/>
          }
          { this.submitLabel() }
        </button>
      </div>
    )
  }
}

TimelineBuilderSubmitButton.propTypes = {
  submissionProgress: React.PropTypes.number,
  submitCB: React.PropTypes.func
};
