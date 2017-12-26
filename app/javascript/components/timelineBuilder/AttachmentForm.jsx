import React from "react";
import PropTypes from "prop-types";
import LinkForm from "./LinkForm";
import FileForm from "./FileForm";
import DateForm from "./DateForm";

export default class AttachmentForm extends React.Component {
  constructor(props) {
    super(props);

    this.displayNewForm = this.displayNewForm.bind(this);
  }

  componentDidUpdate() {
    if (this.props.previousForm != null) {
      // Slide up the old form.
      $(".js-" + this.props.previousForm + "-form").slideUp(
        300,
        this.displayNewForm
      );
    } else {
      this.displayNewForm();
    }
  }

  displayNewForm() {
    if (this.props.currentForm != null) {
      // Slide down the new form.
      $(".js-" + this.props.currentForm + "-form").slideDown(300);
    }
  }

  formVisible(type) {
    if (this.props.previousForm === type) {
      return {};
    } else {
      return { display: "none" };
    }
  }

  render() {
    return (
      <div>
        <div
          className="timeline-builder__attachment-form-container js-link-form"
          style={this.formVisible("link")}
        >
          <LinkForm addAttachmentCB={this.props.addAttachmentCB} />
        </div>

        <div
          className="timeline-builder__attachment-form-container js-file-form"
          style={this.formVisible("file")}
        >
          <FileForm
            addAttachmentCB={this.props.addAttachmentCB}
            resetErrorsCB={this.props.resetErrorsCB}
            showSelectedFileError={this.props.showSelectedFileError}
            hideFileForm={this.props.hideFileForm}
          />
        </div>

        <div
          className="timeline-builder__attachment-form-container js-date-form"
          style={this.formVisible("date")}
        >
          <DateForm
            addAttachmentCB={this.props.addAttachmentCB}
            selectedDate={this.props.selectedDate}
          />
        </div>
      </div>
    );
  }
}

AttachmentForm.propTypes = {
  currentForm: PropTypes.string,
  previousForm: PropTypes.string,
  addAttachmentCB: PropTypes.func,
  selectedDate: PropTypes.string,
  showSelectedFileError: PropTypes.bool,
  resetErrorsCB: PropTypes.func,
  hideFileForm: PropTypes.func
};
