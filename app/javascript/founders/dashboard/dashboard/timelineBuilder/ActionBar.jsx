import React from "react";
import PropTypes from "prop-types";
import SubmitButton from "./SubmitButton";
export default class ActionBar extends React.Component {
  constructor(props) {
    super(props);

    this.showLinkForm = this.showLinkForm.bind(this);
    this.showFileForm = this.showFileForm.bind(this);
    this.disableTab = this.disableTab.bind(this);
  }

  formLinkClasses(type) {
    let classes = "";

    if (type == "link") {
      classes = "timeline-builder__upload-section-tab link-upload";
      classes += this.props.attachmentAllowed ? "" : " action-tab-disabled";
    } else if (type == "file") {
      classes = "timeline-builder__upload-section-tab file-upload";
      classes += this.props.attachmentAllowed ? "" : " action-tab-disabled";
    }

    if (this.props.currentForm == type) {
      classes += " timeline-builder__active-tab";
    }

    return classes;
  }

  showLinkForm() {
    if (this.props.attachmentAllowed) {
      this.props.formClickedCB("link");
    }
  }

  showFileForm() {
    if (this.props.attachmentAllowed) {
      this.props.formClickedCB("file");
    }
  }

  disableTab() {
    return this.props.submissionProgress != null;
  }

  render() {
    return (
      <div className="timeline-builder__submit-tabs">
        <div className="timeline-builder__upload-section">
          <div
            className={this.formLinkClasses("link")}
            onClick={this.showLinkForm}
          >
            <i className="timeline-builder__upload-section-icon fa fa-link" />
            <span className="timeline-builder__tab-label">Link</span>
          </div>
          <div
            className={this.formLinkClasses("file")}
            onClick={this.showFileForm}
          >
            <i className="timeline-builder__upload-section-icon fa fa-file-text-o" />
            <span className="timeline-builder__tab-label">File</span>
          </div>
        </div>
        <div className="d-flex timeline-builder__select-section">
          <SubmitButton
            submissionProgress={this.props.submissionProgress}
            submitCB={this.props.submitCB}
            submissionError={this.props.submissionError}
            submissionSuccessful={this.props.submissionSuccessful}
          />
        </div>
      </div>
    );
  }
}

ActionBar.propTypes = {
  formClickedCB: PropTypes.func,
  currentForm: PropTypes.string,
  submitCB: PropTypes.func,
  coverImage: PropTypes.object,
  addDataCB: PropTypes.func,
  addAttachmentCB: PropTypes.func,
  submissionProgress: PropTypes.number,
  submissionError: PropTypes.string,
  submissionSuccessful: PropTypes.bool,
  attachmentAllowed: PropTypes.bool,
  showEventTypeError: PropTypes.bool,
  resetErrorsCB: PropTypes.func
};
