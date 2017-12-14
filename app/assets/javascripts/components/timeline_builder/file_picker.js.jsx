class TimelineBuilderFilePicker extends React.Component {
  constructor(props) {
    super(props);
    this.state = { fileLabel: "" };
    this.handleChange = this.handleChange.bind(this);
  }

  componentDidUpdate() {
    if (this.props.showSelectedFileError) {
      let fileLabel = $(".timeline-builder__file-label");
      fileLabel.popover({
        trigger: "manual",
        placement: "bottom",
        title: "Forgetting something?",
        content:
          "Do you want to upload this file? If so, please click the <em>Add File</em> button.",
        html: true
      });

      fileLabel.popover("show");
    } else {
      $(".timeline-builder__file-label").popover("hide");
    }
  }

  componentWillUnmount() {
    $(".timeline-builder__file-label").popover("dispose");
  }

  handleChange(event) {
    let fileName = $(event.target)
      .val()
      .split("\\")
      .pop();
    let newLabelText = fileName ? fileName : "";
    this.setState({ fileLabel: newLabelText });
    this.props.clearErrorsCB();
  }

  hasAnyError() {
    return this.props.fileMissingError || this.props.fileSizeError;
  }

  formGroupClassNames() {
    return (
      "form-group timeline-builder__form-group" +
      (this.hasAnyError() ? " has-danger" : "")
    );
  }

  labelText() {
    if (this.state.fileLabel.length > 0) {
      return this.state.fileLabel;
    } else {
      return "CHOOSE FILE";
    }
  }

  fileInputClasses() {
    const classes =
      "form-control form-control-file timeline-builder__file-input js-hook";

    if (this.props.fileMissingError || this.props.fileSizeError) {
      return classes + " is-invalid";
    }

    return classes;
  }

  invalidFeedback() {
    if (this.props.fileMissingError) {
      return "Choose a valid file!";
    } else {
      return "Size cannot exceed 5MB!";
    }
  }

  render() {
    return (
      <div className={this.formGroupClassNames()}>
        <input
          type="file"
          className={this.fileInputClasses()}
          id="timeline-builder__file-input"
          onChange={this.handleChange}
        />
        <label
          className="timeline-builder__file-label"
          htmlFor="timeline-builder__file-input"
        >
          <div className="timeline-builder__choose-file-btn">
            <i className="timeline-builder__choose-file-btn-icon fa fa-upload" />
            <span className="timeline-builder__choose-file-button-text">
              {this.labelText()}
            </span>
          </div>
        </label>

        <div className="invalid-feedback">{this.invalidFeedback()}</div>
      </div>
    );
  }
}

TimelineBuilderFilePicker.propTypes = {
  clearErrorsCB: PropTypes.func,
  fileMissingError: PropTypes.bool,
  fileSizeError: PropTypes.bool,
  showSelectedFileError: PropTypes.bool
};
