import React from "react";
import PropTypes from "prop-types";
import TextArea from "./timelineBuilder/TextArea";
import SocialBar from "./timelineBuilder/SocialBar";
import AttachmentForm from "./timelineBuilder/AttachmentForm";
import ActionBar from "./timelineBuilder/ActionBar";
import Attachments from "./timelineBuilder/Attachments";

export default class TimelineBuilder extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      links: [],
      files: {},
      date: this.today(),
      coverImage: null,
      showLinkForm: false,
      showFileForm: false,
      previousForm: null,
      imageButtonKey: this.generateKey(),
      submissionProgress: null,
      submissionError: null,
      submissionSuccessful: false,
      descriptionError: null,
      showDateError: false,
      showEventTypeError: false,
      showSelectedFileError: false,
      timelineEventTypeId: this.props.selectedTimelineEventTypeId,
      description: ""
    };

    this.toggleForm = this.toggleForm.bind(this);
    this.currentForm = this.currentForm.bind(this);
    this.hideFileForm = this.hideFileForm.bind(this);
    this.attachmentAllowed = this.attachmentAllowed.bind(this);
    this.attachmentsCount = this.attachmentsCount.bind(this);
    this.addData = this.addData.bind(this);
    this.removeAttachment = this.removeAttachment.bind(this);
    this.removeCoverImageFromHiddenForm = this.removeCoverImageFromHiddenForm.bind(
      this
    );
    this.removeFileFromHiddenForm = this.removeFileFromHiddenForm.bind(this);
    this.submit = this.submit.bind(this);
    this.xhrCallback = this.xhrCallback.bind(this);
    this.validate = this.validate.bind(this);
    this.resetErrors = this.resetErrors.bind(this);
    this.handleBeforeSubmission = this.handleBeforeSubmission.bind(this);
    this.handleSubmissionProgress = this.handleSubmissionProgress.bind(this);
    this.handleSubmissionError = this.handleSubmissionError.bind(this);
    this.handleSubmissionComplete = this.handleSubmissionComplete.bind(this);
    this.updateDescription = this.updateDescription.bind(this);
  }

  componentDidMount() {
    let timelineBuilderModal = $(".timeline-builder");

    // Now show the form. Ensure it can only be closed by clicking appropriate button.
    timelineBuilderModal.modal({
      show: true,
      keyboard: false,
      backdrop: "static"
    });

    timelineBuilderModal.on("hide.bs.modal", this.destroyPopovers);
    timelineBuilderModal.on(
      "hidden.bs.modal",
      this.props.closeTimelineBuilderCB
    );
  }

  destroyPopovers() {
    $(".js-timeline-builder__textarea").popover("dispose");
    $(".date-of-event").popover("dispose");
    $(".js-timeline-builder__timeline-event-type-select-wrapper").popover(
      "dispose"
    );
    $(".js-timeline-builder__submit-button").popover("dispose");
    $(".image-upload").popover("dispose");
    $(".timeline-builder__social-bar-toggle-switch").popover("dispose");
  }

  generateKey() {
    return "" + new Date().getTime();
  }

  toggleForm(type) {
    let previousForm = this.currentForm();

    this.resetErrors();

    if (type == "link") {
      let newState = !this.state.showLinkForm;
      this.setState({
        showLinkForm: newState,
        showFileForm: false,
        previousForm: previousForm
      });
    } else {
      let newState = !this.state.showFileForm;
      this.setState({
        showLinkForm: false,
        showFileForm: newState,
        previousForm: previousForm
      });
    }
  }

  currentForm() {
    if (this.state.showLinkForm) {
      return "link";
    } else if (this.state.showFileForm) {
      return "file";
    } else {
      return null;
    }
  }

  hideFileForm() {
    this.setState({ showFileForm: false, previousForm: "file" });
  }

  hasAttachments() {
    return (
      this.state.links.length > 0 ||
      !$.isEmptyObject(this.state.files) ||
      this.state.coverImage != null
    );
  }

  attachments() {
    let currentAttachments = [];

    if (this.state.coverImage != null) {
      currentAttachments.push({
        type: "cover",
        title: this.state.coverImage.title,
        private: false
      });
    }

    this.state.links.forEach(function(link, index) {
      currentAttachments.push({
        type: "link",
        index: index,
        title: link.title,
        private: link.private
      });
    });

    $.each(this.state.files, function(identifier, file_data) {
      currentAttachments.push({
        type: "file",
        index: identifier,
        title: file_data.title,
        private: file_data.private
      });
    });

    return currentAttachments;
  }

  attachmentsCount() {
    return this.state.links.length + Object.keys(this.state.files).length;
  }

  attachmentAllowed() {
    return this.attachmentsCount() < 3 && this.state.submissionProgress == null;
  }

  addData(type, properties) {
    if (type == "link") {
      this.setState({ links: this.state.links.concat([properties]) });
      this.toggleForm("link");
    } else if (type == "file") {
      let updatedFiles = $.extend(true, {}, this.state.files);
      updatedFiles[properties.identifier] = properties;
      this.setState({ files: updatedFiles });
      this.toggleForm("file");
    } else if (type == "cover") {
      // The key for image button is regenerated to ensure the button component is regenerated.
      this.setState({
        coverImage: { title: "Cover Image" },
        imageButtonKey: this.generateKey()
      });
    } else if (type == "date") {
      this.setState({ date: properties.value });
    } else if (type == "timeline_event_type") {
      this.setState({ timelineEventTypeId: properties.id });
    } else {
      console.warn("Unhandled attachment type: ", type);
    }
  }

  removeAttachment(type, index) {
    switch (type) {
      case "cover":
        this.removeCoverImageFromHiddenForm();
        this.setState({ coverImage: null });
        break;
      case "link":
        let updatedLinks = this.state.links.slice();
        updatedLinks.splice(index, 1);
        this.setState({ links: updatedLinks });
        break;
      case "file":
        let updatedFiles = $.extend(true, {}, this.state.files);
        delete updatedFiles[index];
        this.removeFileFromHiddenForm(index);
        this.setState({ files: updatedFiles });
        break;
      default:
        console.warn(
          "Unable to handle instruction to remove attachment of type " + type
        );
    }
  }

  removeCoverImageFromHiddenForm() {
    $('[name="timeline_event[image]"]').remove();
  }

  removeFileFromHiddenForm(identifier) {
    $('[name="timeline_event[files][' + identifier + ']"').remove();
  }

  submit() {
    if (this.state.showLinkForm) {
      $(".js-timeline-builder__add-link-button").trigger("click");
    } else if (this.state.showFileForm) {
      $(".js-timeline-builder__add-file-button").trigger("click");
    } else if ($(".js-hook.timeline-builder__file-input").val() !== "") {
      // Open the form, show the error, and hide it after a short while.
      this.toggleForm("file");

      let that = this;

      setTimeout(function() {
        that.setState({ showSelectedFileError: true });
      }, 300);

      setTimeout(function() {
        that.setState({ showSelectedFileError: false });
      }, 5000);
    } else if (!navigator.onLine) {
      this.setState({ submissionError: "offline" }, function() {
        $(".js-timeline-builder__submit-button").popover("show");

        setTimeout(function() {
          $(".js-timeline-builder__submit-button").popover("hide");
        }, 3000);
      });
    } else if (this.validate()) {
      let form = $(".timeline-builder-hidden-form");
      let formData = new FormData(form[0]);
      let share_on_facebook = false;

      if (this.props.facebookShareEligibility == "eligible") {
        share_on_facebook = $(
          ".timeline-builder__social-bar-toggle-switch-input"
        ).prop("checked");
      }

      formData.append("timeline_event[target_id]", this.props.targetId);
      formData.append("timeline_event[description]", this.state.description);
      formData.append("timeline_event[event_on]", this.state.date);
      formData.append(
        "timeline_event[links]",
        JSON.stringify(this.state.links)
      );
      formData.append(
        "timeline_event[files_metadata]",
        JSON.stringify(this.state.files)
      );
      formData.append(
        "timeline_event[timeline_event_type_id]",
        this.state.timelineEventTypeId
      );
      formData.append("timeline_event[share_on_facebook]", share_on_facebook);

      // Submit form data using AJAX and set a progress handler function.
      $.ajax({
        url: form.attr("action"),
        type: form.attr("method"),

        xhr: this.xhrCallback,

        // Ajax events.
        beforeSend: this.handleBeforeSubmission,
        success: this.handleSubmissionComplete,
        error: this.handleSubmissionError,

        // Form data
        data: formData,

        // Options to tell jQuery not to process data or worry about content-type.
        cache: false,
        contentType: false,
        processData: false
      });
    }
  }

  xhrCallback() {
    let myXhr = $.ajaxSettings.xhr();

    if (myXhr.upload != null) {
      // Check if upload property exists.
      // For handling the progress of the upload.
      myXhr.upload.addEventListener(
        "progress",
        this.handleSubmissionProgress,
        false
      );
    }

    return myXhr;
  }

  validate() {
    if (
      $(".timeline-builder__textarea")
        .val()
        .trim().length == 0
    ) {
      this.setState({ descriptionError: "description_missing" });
      return false;
    }

    if (
      $(".timeline-builder__textarea")
        .val()
        .trim().length > 500
    ) {
      this.setState({ descriptionError: "description_too_long" });
      return false;
    }

    if (this.state.date == null) {
      this.setState({ showDateError: true });
      return false;
    }

    if (this.state.timelineEventTypeId == null) {
      this.setState({ showEventTypeError: true });
      return false;
    }

    return true;
  }

  resetErrors() {
    this.setState({
      descriptionError: null,
      showDateError: false,
      showEventTypeError: false,
      showSelectedFileError: false
    });
  }

  handleBeforeSubmission() {
    this.setState({ submissionProgress: -1 });
  }

  handleSubmissionProgress(event) {
    if (event.lengthComputable) {
      let percentDone = Math.round(event.loaded / event.total * 100);
      this.setState({ submissionProgress: percentDone });
    }
  }

  handleSubmissionError(jqXHR) {
    if (jqXHR.status >= 500) {
      this.setState({ submissionError: "5XX" }, function() {
        $(".js-timeline-builder__submit-button").popover("show");
      });
    } else {
      this.setState({ submissionError: "other" }, function() {
        $(".js-timeline-builder__submit-button").popover("show");
      });
    }
  }

  handleSubmissionComplete() {
    // show done on timeline builder
    this.setState({ submissionSuccessful: true });

    // mark target submitted, if applicable
    if (this.props.targetId) {
      this.props.targetSubmissionCB(this.props.targetId);
    }

    // hide the timeline builder
    $(".timeline-builder").modal("hide");
  }

  sampleText() {
    if (this.state.timelineEventTypeId == null) {
      return null;
    } else {
      let timelineEventTypeId = this.state.timelineEventTypeId.toString();

      for (let role in this.props.timelineEventTypes) {
        let role_types = this.props.timelineEventTypes[role];

        if (timelineEventTypeId in role_types) {
          return role_types[timelineEventTypeId]["sample"];
        }
      }

      return null;
    }
  }

  timelineEventTypeIdForSelect() {
    if (this.state.timelineEventTypeId == null) {
      return "";
    } else {
      return this.state.timelineEventTypeId.toString();
    }
  }

  updateDescription() {
    let description = $(".js-timeline-builder__textarea")
      .val()
      .trim();
    this.setState({ description: description });
  }

  today() {
    return moment().format("YYYY-MM-DD");
  }

  modalClasses() {
    let classes = "timeline-builder modal";

    if (!this.props.testMode) {
      classes += " fade";
    }

    return classes;
  }

  render() {
    return (
      <div className={this.modalClasses()}>
        <div className="modal-dialog timeline-builder__popup">
          <div className="modal-content timeline-builder__popup-content">
            <div className="timeline-builder__popup-body">
              <button
                type="button"
                className="close timeline-builder__modal-close"
                data-dismiss="modal"
                aria-label="Close"
              >
                <span aria-hidden="true">&times;</span>
              </button>

              <form
                className="timeline-builder-hidden-form js-timeline-builder__hidden-form"
                action="/timeline_events"
                acceptCharset="UTF-8"
                method="post"
              >
                <input name="utf8" type="hidden" value="✓" />
                <input
                  type="hidden"
                  name="authenticity_token"
                  value={this.props.authenticityToken}
                />
              </form>

              <TextArea
                error={this.state.descriptionError}
                resetErrorsCB={this.resetErrors}
                placeholder={this.sampleText()}
                textChangeCB={this.updateDescription}
              />

              <SocialBar
                description={this.state.description}
                facebookShareEligibility={this.props.facebookShareEligibility}
              />

              {this.hasAttachments() && (
                <Attachments
                  attachments={this.attachments()}
                  removeAttachmentCB={this.removeAttachment}
                />
              )}

              <AttachmentForm
                currentForm={this.currentForm()}
                previousForm={this.state.previousForm}
                addAttachmentCB={this.addData}
                selectedDate={this.state.date}
                showSelectedFileError={this.state.showSelectedFileError}
                resetErrorsCB={this.resetErrors}
                hideFileForm={this.hideFileForm}
              />

              <ActionBar
                addAttachmentCB={this.addData}
                formClickedCB={this.toggleForm}
                currentForm={this.currentForm()}
                submitCB={this.submit}
                timelineEventTypes={this.props.timelineEventTypes}
                addDataCB={this.addData}
                coverImage={this.state.coverImage}
                imageButtonKey={this.state.imageButtonKey}
                selectedDate={this.state.date}
                submissionProgress={this.state.submissionProgress}
                attachmentAllowed={this.attachmentAllowed()}
                showDateError={this.state.showDateError}
                resetErrorsCB={this.resetErrors}
                showEventTypeError={this.state.showEventTypeError}
                timelineEventTypeId={this.timelineEventTypeIdForSelect()}
                submissionError={this.state.submissionError}
                submissionSuccessful={this.state.submissionSuccessful}
              />
            </div>
          </div>
        </div>
      </div>
    );
  }
}

TimelineBuilder.propTypes = {
  timelineEventTypes: PropTypes.object,
  selectedTimelineEventTypeId: PropTypes.number,
  targetId: PropTypes.number,
  facebookShareEligibility: PropTypes.string,
  authenticityToken: PropTypes.string,
  closeTimelineBuilderCB: PropTypes.func,
  targetSubmissionCB: PropTypes.func,
  testMode: PropTypes.bool
};
