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

  inputId() {
    return 'answer-option-' + this.props.text;
  }

  render() {
    return (
      <label className="custom-control custom-radio applicant-screening__answer-option-label"
        htmlFor={ this.inputId() }>
        <input className="custom-control-input applicant-screening__answer-option-input" type="radio"
          name='answer-option' id={ this.inputId() } onChange={ this.handleChange } value={ this.props.text }/>
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
