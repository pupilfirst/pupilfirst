class TimelineBuilderTextArea extends React.Component {
  constructor(props) {
    super(props);
    this.resetErrors = this.resetErrors.bind(this);
  }

  componentDidUpdate() {
    if (this.props.error !== null) {
      let popover = $(".js-timeline-builder__textarea").popover({
        title: this.errorTitle(),
        content: this.errorDescription()
      });

      popover.popover("show");
    } else {
      $(".js-timeline-builder__textarea").popover("hide");
    }
  }

  componentWillUpdate() {
    $(".js-timeline-builder__textarea").popover("dispose");
  }

  resetErrors() {
    this.props.resetErrorsCB();
  }

  placeholder() {
    if (this.props.placeholder == null) {
      return "What’s been happening?";
    } else {
      return this.props.placeholder;
    }
  }

  errorTitle() {
    switch (this.props.error) {
      case "description_missing":
        return "Description Missing!";
      case "description_too_long":
        return "Description is too long!";
    }
  }

  errorDescription() {
    switch (this.props.error) {
      case "description_missing":
        return "Please add a summary describing the event.";
      case "description_too_long":
        return "Please restrict description to under 500 characters.";
    }
  }

  render() {
    return (
      <textarea
        className="form-control js-timeline-builder__textarea timeline-builder__textarea"
        rows="4"
        data-toggle="popover"
        placeholder={this.placeholder()}
        data-placement="bottom"
        data-trigger="manual"
        onFocus={this.resetErrors}
        onChange={this.props.textChangeCB}
        maxLength="500"
      />
    );
  }
}

TimelineBuilderTextArea.propTypes = {
  showError: PropTypes.bool,
  resetErrorsCB: PropTypes.func,
  placeholder: PropTypes.string,
  textChangeCB: PropTypes.func
};

TimelineBuilderTextArea.defaultProps = {
  error: null
};
