class ApplicantScreeningQuizResult extends React.Component {
  constructor(props) {
    super(props);
    this.submit = this.submit.bind(this);
  }

  submit() {
    if (this.props.passed) {
      $('#applicant-screening__hidden-form').submit();
    } else {
      this.props.resetCB();
    }
  }

  buttonText() {
    return this.props.passed ? 'Continue Application' : 'Restart'
  }

  buttonClasses() {
    let classes = "btn btn-with-icon btn-md text-uppercase";

    if (this.props.passed) {
      classes += ' btn-primary';
    } else {
      classes += ' btn-secondary';
    }

    return classes;
  }

  buttonIconClasses() {
    let classes = 'fa';

    if (this.props.passed) {
      classes += ' fa-arrow-right'
    } else {
      classes += ' fa-refresh'
    }

    return classes;
  }

  heading() {
    if (this.props.passed) {
      return {__html: '&#x1F389;&nbsp;Congratulations'}
    } else {
      return {__html: '&#x1F61F;&nbsp;Sorry'}
    }
  }

  render() {
    return (
      <div className="applicant-screening__quiz-result">
        <h3 className="font-semibold brand-primary m-b-2" dangerouslySetInnerHTML={ this.heading() }/>

        { this.props.passed && this.props.type === 'coder' &&
        <ApplicantScreeningCoderPassed/>
        }

        { this.props.passed && this.props.type === 'non-coder' &&
        <ApplicantScreeningNonCoderPassed/>
        }

        { !this.props.passed && this.props.type === 'coder' &&
        <ApplicantScreeningCoderFailed/>
        }

        { !this.props.passed && this.props.type === 'non-coder' &&
        <ApplicantScreeningNonCoderFailed/>
        }

        <button className={ this.buttonClasses() } onClick={ this.submit }>
          <i className={ this.buttonIconClasses() }/> { this.buttonText() }
        </button>
      </div>
    );
  }
}

ApplicantScreeningQuizResult.propTypes = {
  passed: React.PropTypes.bool,
  resetCB: React.PropTypes.func,
  type: React.PropTypes.string
};
