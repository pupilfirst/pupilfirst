class ApplicantScreeningAnswerOption extends React.Component {
  constructor(props) {
    super(props);

    this.handleChange = this.handleChange.bind(this);
  }

  handleChange(event) {
    if (event.target.checked) {
      this.props.selectAnswerCB(this.props.text)
    }
  }

  render() {
    return (
      <label className="custom-control custom-radio applicant-screening__answer-option-label">
        <input className="custom-control-input applicant-screening__answer-option-input" type="radio" name="foo"
          onChange={ this.handleChange }/>
        <span className="custom-control-indicator applicant-screening__answer-option-indicator"/>
        <span className="custom-control-description applicant-screening__answer-option-description">
          { this.props.text }
        </span>
      </label>
    );
  }
}

ApplicantScreeningAnswerOption.propTypes = {
  text: React.PropTypes.string,
  selectAnswerCB: React.PropTypes.func
};
