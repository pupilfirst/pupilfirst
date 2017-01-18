class CofoundersFormCofounderInput extends React.Component {
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
    return "batch_applications_cofounders[cofounders_attributes][" + this.props.index + "][" + this.props.name + "]";
  }

  inputId() {
    return "cofounders-form__cofounder-" + this.props.name + "-input-" + this.props.index;
  }

  hasError() {
    return typeof(this.props.error) !== 'undefined';
  }

  render() {
    return (
      <div className={ this.wrapperClasses() }>
        <label className={ this.labelClasses() } htmlFor={ this.inputId() }>
          <abbr title="required">*</abbr> { this.props.label }
        </label>

        <input className={ this.inputClasses() } maxLength={ this.props.maxLength } required="required"
               aria-required="true" size={ this.props.maxLength } type={ this.inputType() } name={ this.inputName() }
               id={ this.inputId() } pattern={ this.props.pattern }/>
        { this.hasError() &&
        <span className="help-block">{ this.props.error }</span>
        }
      </div>
    )
  }
}

CofoundersFormCofounderInput.PropTypes = {
  label: React.PropTypes.string,
  index: React.PropTypes.number,
  maxLength: React.PropTypes.number,
  name: React.PropTypes.string,
  type: React.PropTypes.string,
  pattern: React.PropTypes.string,
  error: React.PropTypes.string
};
