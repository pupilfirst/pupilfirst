class FoundersFormFounderInput extends React.Component {
  componentDidMount() {
    document.getElementById(this.inputId()).focus();
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

  render() {
    return (
      <div className={ this.wrapperClasses() }>
        <label className={ this.labelClasses() } htmlFor={ this.inputId() }>
          <abbr title="required">*</abbr> { this.props.label }
        </label>

        <input className={ this.inputClasses() } maxLength={ this.props.maxLength } required="required"
          aria-required="true" size={ this.props.maxLength } type={ this.inputType() } name={ this.inputName() }
          id={ this.inputId() } pattern={ this.props.pattern } defaultValue={ this.props.value }
          disabled={ this.props.disabled }/>
        { this.hasError() &&
        <span className="help-block">{ this.props.error }</span>
        }
      </div>
    )
  }
}

FoundersFormFounderInput.PropTypes = {
  label: React.PropTypes.string,
  index: React.PropTypes.number,
  maxLength: React.PropTypes.number,
  name: React.PropTypes.string,
  type: React.PropTypes.string,
  pattern: React.PropTypes.string,
  error: React.PropTypes.string,
  value: React.PropTypes.string,
  disabled: React.PropTypes.bool,
};
