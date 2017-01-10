class TimelineBuilderTextArea extends React.Component {
  constructor(props) {
    super(props);
    this.resetErrors = this.resetErrors.bind(this);
  }

  componentDidUpdate() {
    if (this.props.showError) {
      $('.js-timeline-builder__textarea').popover('show');
    } else {
      $('.js-timeline-builder__textarea').popover('hide');
    }
  }

  resetErrors() {
    this.props.resetErrorsCB();
  }

  placeholder() {
    if (this.props.placeholder == null) {
      return 'What’s been happening?';
    } else {
      return this.props.placeholder;
    }
  }

  render() {
    return (
      <textarea className="form-control js-timeline-builder__textarea timeline-builder__textarea" rows="4"
                data-toggle="popover" data-title="Description Missing!" placeholder={ this.placeholder() }
                data-content="Please add a summary describing the event." data-placement="bottom" data-trigger="manual"
                onFocus={ this.resetErrors } onChange={ this.props.textChangeCB } maxLength="300"/>
    )
  }
}

TimelineBuilderTextArea.propTypes = {
  showError: React.PropTypes.bool,
  resetErrorsCB: React.PropTypes.func,
  placeholder: React.PropTypes.string,
  textChangeCB: React.PropTypes.func
};
