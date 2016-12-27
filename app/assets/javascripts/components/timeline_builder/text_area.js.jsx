class TimelineBuilderTextArea extends React.Component {
  constructor(props) {
    super(props);

    this.state = {counterText: ''};

    this.resetErrors = this.resetErrors.bind(this);
    this.updateCounter = this.updateCounter.bind(this);
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

  updateCounter() {
    if (  this.textCount() == 0) {
      this.setState({counterText: ''});
      return;
    } else {
      let text = this.textCount() + "/300";
      this.setState({counterText: text});
      return;
    }
  }

  textCount() {
    let text = $('.js-timeline-builder__textarea').val();
    return (text ? text.length : 0);
  }

  counterClasses() {
    let textClass ='';
    if (this.textCount() == 300) {
      textClass = "timeline-builder__textarea__counter--danger";
    } else if (this.textCount() > 200) {
      textClass = "timeline-builder__textarea__counter--warning";
    }
    return "timeline-builder__textarea__counter " + textClass;
  }

  render() {
    return (
      <div className="timeline-builder__textarea-wrapper">
      <textarea className="form-control js-timeline-builder__textarea timeline-builder__textarea" rows="4"
                data-toggle="popover" data-title="Description Missing!" placeholder={ this.placeholder() }
                data-content="Please add a summary describing the event." data-placement="bottom" data-trigger="manual"
                onFocus={ this.resetErrors } onChange={ this.updateCounter } maxLength="300"/>
      <div className={ this.counterClasses() }>{ this.state.counterText }</div>
      </div>
    )
  }
}

TimelineBuilderTextArea.propTypes = {
  showError: React.PropTypes.bool,
  resetErrorsCB: React.PropTypes.func,
  placeholder: React.PropTypes.string
};
