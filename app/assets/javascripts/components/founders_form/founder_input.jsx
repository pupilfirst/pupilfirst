class FoundersFormFounderInput extends React.Component {
  constructor(props) {
    super(props);
    this.acceptEmailHint = this.acceptEmailHint.bind(this);
    this.rejectEmailHint = this.rejectEmailHint.bind(this);
  }

  componentDidMount() {
    if (this.props.autofocus) {
      $('#' + this.inputId()).focus();
    }
  }

  wrapperClasses() {
    let baseClasses = "form-group required " + this.props.type;

    if (this.hasError()) {
      return baseClasses + " has-error";
    } else {
      return baseClasses;
    }
  }

  labelClasses() {
    return "control-label required " + this.props.type;
  }

  inputClasses() {
    return "form-control required " + this.props.type;
  }

  inputType() {
    if (this.props.type === 'string') {
      return 'text';
    } else {
      return this.props.type;
    }
  }

  inputName() {
    return "admissions_founders[founders_attributes][" + this.props.index + "][" + this.props.name + "]";
  }

  inputId() {
    return "founders-form__founder-" + this.props.name + "-input-" + this.props.index;
  }

  hasError() {
    return this.props.error !== null;
  }

  hasReplacement() {
    return this.props.error === 'email could be incorrect'
  }

  acceptEmailHint() {
    this.props.handleReplacementChoiceCB('yes', this.inputId());
  }

  rejectEmailHint() {
    this.props.handleReplacementChoiceCB('no');
  }

  emailHint() {
    return <span className="help-block">
      Did you mean <strong>{ this.props.replacementHint }</strong>?<br/>
      <a id='founder-form__password-hint-accept' onClick={ this.acceptEmailHint }
         className='btn btn-sm btn-success application-form__email-hint-button m-r-1'>Yes</a>
      <a id='founder-form__password-hint-reject' onClick={ this.rejectEmailHint }
         className='btn btn-sm btn-danger application-form__email-hint-button'>No</a>
    </span>;
  }

  render() {
    return (
      <div className={this.wrapperClasses()}>
        <label className={this.labelClasses()} htmlFor={this.inputId()}>
          <abbr title="required">*</abbr> {this.props.label}
        </label>

        <input className={this.inputClasses()} maxLength={this.props.maxLength} required="required"
               aria-required="true" size={this.props.maxLength} type={this.inputType()} name={this.inputName()}
               id={this.inputId()} pattern={this.props.pattern} defaultValue={this.props.value}
               disabled={this.props.disabled}/>
        {this.hasError() && !this.hasReplacement() &&
        <span className="help-block">{this.props.error}</span>
        }
        {this.props.showEmailHint && this.hasReplacement() && this.emailHint()}
      </div>
    )
  }
}

FoundersFormFounderInput.PropTypes = {
  autofocus: PropTypes.bool,
  label: PropTypes.string,
  index: PropTypes.number,
  maxLength: PropTypes.number,
  name: PropTypes.string,
  type: PropTypes.string,
  pattern: PropTypes.string,
  error: PropTypes.string,
  value: PropTypes.string,
  disabled: PropTypes.bool,
  replacementHint: PropTypes.string,
  handleReplacementChoiceCB: PropTypes.func,
  showEmailHint: PropTypes.bool
};

FoundersFormFounderInput.defaultProps = {
  autofocus: false
};
