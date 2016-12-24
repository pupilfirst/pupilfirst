const TimelineBuilder = React.createClass({
  propTypes: {
    timelineEventTypes: React.PropTypes.object,
    selectedTimelineEventTypeId: React.PropTypes.number,
    targetId: React.PropTypes.number
  },

  getInitialState: function () {
    return {
      links: [],
      files: {},
      date: null,
      coverImage: null,
      showLinkForm: false,
      showFileForm: false,
      showDateForm: false,
      previousForm: null,
      imageButtonKey: this.generateKey(),
      submissionProgress: null,
      hasSubmissionError: false,
      showDescriptionError: false,
      showDateError: false,
      showEventTypeError: false,
      timelineEventTypeId: this.props.selectedTimelineEventTypeId
    }
  },

  componentDidMount: function () {
    // Remove all file inputs from hidden form.
    $('.timeline-builder-hidden-form').find('input[type="file"]').remove();
  },

  generateKey: function () {
    return '' + (new Date).getTime();
  },

  toggleForm: function (type) {
    let previousForm = this.currentForm();

    if (type == 'link') {
      let newState = !this.state.showLinkForm;
      this.setState({showLinkForm: newState, showFileForm: false, showDateForm: false, previousForm: previousForm});
    } else if (type == 'file') {
      let newState = !this.state.showFileForm;
      this.setState({showLinkForm: false, showFileForm: newState, showDateForm: false, previousForm: previousForm});
    } else {
      let newState = !this.state.showDateForm;
      this.setState({showLinkForm: false, showFileForm: false, showDateForm: newState, previousForm: previousForm});
    }
  },

  currentForm: function () {
    if (this.state.showLinkForm) {
      return 'link';
    } else if (this.state.showFileForm) {
      return 'file';
    } else if (this.state.showDateForm) {
      return 'date';
    } else {
      return null;
    }
  },

  hasAttachments: function () {
    return this.state.links.length > 0 || !$.isEmptyObject(this.state.files) || this.state.coverImage != null;
  },

  attachments: function () {
    let currentAttachments = [];

    if (this.state.coverImage != null) {
      currentAttachments.push({type: 'cover', title: this.state.coverImage.title});
    }

    this.state.links.forEach(function (link, index) {
      currentAttachments.push({type: 'link', index: index, title: link.title})
    });

    $.each(this.state.files, function (identifier, file_data) {
      currentAttachments.push({type: 'file', index: identifier, title: file_data.title})
    });

    return currentAttachments;
  },

  attachmentsCount: function () {
    return this.state.links.length + Object.keys(this.state.files).length
  },

  attachmentAllowed: function () {
    return this.attachmentsCount() < 3;
  },

  addData: function (type, properties) {
    if (type == 'link') {
      this.setState({links: this.state.links.concat([properties])});
      this.toggleForm('link')
    } else if (type == 'file') {
      let updatedFiles = $.extend(true, {}, this.state.files);
      updatedFiles[properties.identifier] = properties;
      this.setState({files: updatedFiles});
      this.toggleForm('file')
    } else if (type == 'cover') {
      // The key for image button is regenerated to ensure the button component is regenerated.
      this.setState({coverImage: {title: 'Cover Image'}, imageButtonKey: this.generateKey()});
    } else if (type == 'date') {
      this.setState({date: properties.value});

      if (properties.hideDateForm) {
        this.toggleForm('date');
      }
    } else if (type == 'timeline_event_type') {
      this.setState({timelineEventTypeId: properties.id});
    } else {
      console.warn('Unhandled attachment type: ', type)
    }
  },

  removeAttachment: function (type, index) {
    switch (type) {
      case 'cover':
        this.removeCoverImageFromHiddenForm();
        this.setState({coverImage: null});
        break;
      case 'link':
        let updatedLinks = this.state.links.slice();
        updatedLinks.splice(index, 1);
        this.setState({links: updatedLinks});
        break;
      case 'file':
        let updatedFiles = $.extend(true, {}, this.state.files);
        delete updatedFiles[index];
        this.removeFileFromHiddenForm(index);
        this.setState({files: updatedFiles});
        break;
      default:
        console.warn("Unable to handle instruction to remove attachment of type " + type);
    }
  },

  removeCoverImageFromHiddenForm: function () {
    $('[name="timeline_event[image]"]').remove()
  },

  removeFileFromHiddenForm: function (identifier) {
    $('[name="timeline_event[files][' + identifier + ']"').remove()
  },

  submit: function (event) {
    if (this.validate()) {

      let form = $('.timeline-builder-hidden-form');
      let formData = new FormData(form[0]);

      let description = $('.js-timeline-builder__textarea').val();

      formData.append('timeline_event[target_id]', this.props.targetId);
      formData.append('timeline_event[description]', description);
      formData.append('timeline_event[event_on]', this.state.date);
      formData.append('timeline_event[links]', JSON.stringify(this.state.links));
      formData.append('timeline_event[files_metadata]', JSON.stringify(this.state.files));
      formData.append('timeline_event[timeline_event_type_id]', this.state.timelineEventTypeId);

      // Submit form data using AJAX and set a progress handler function.
      $.ajax({
        url: form.attr('action'),
        type: form.attr('method'),

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
  },

  xhrCallback: function () {
    let myXhr = $.ajaxSettings.xhr();

    if (myXhr.upload != null) { // Check if upload property exists.
      // For handling the progress of the upload.
      myXhr.upload.addEventListener('progress', this.handleSubmissionProgress, false);
    }

    return myXhr;
  },

  validate: function () {
    if ($('.timeline-builder__textarea').val().length == 0) {
      this.setState({showDescriptionError: true});
      return false;
    }

    if (this.state.date == null) {
      this.setState({showDateError: true});
      return false;
    }

    if (this.state.timelineEventTypeId == null) {
      this.setState({showEventTypeError: true});
      return false;
    }

    return true;
  },

  resetErrors: function () {
    this.setState({
      showDescriptionError: false,
      showDateError: false,
      showEventTypeError: false
    });
  },

  handleBeforeSubmission: function () {
    this.setState({submissionProgress: -1})
  },

  handleSubmissionProgress: function (event) {
    if (event.lengthComputable) {
      let percentDone = Math.round((event.loaded / event.total) * 100);
      this.setState({submissionProgress: percentDone});
    }
  },

  handleSubmissionError: function () {
    this.setState({hasSubmissionError: true});
    $('.js-timeline-builder__submit-button').popover('show');
  },

  handleSubmissionComplete: function () {
    location.reload();
  },

  sampleText: function () {
    if (this.state.timelineEventTypeId == null) {
      return null;
    } else {
      let filtered = Object.values(this.props.timelineEventTypes).filter(function (element) {
        return this.state.timelineEventTypeId.toString() in element;
      }, this);

      if (filtered.length > 0) {
        return filtered[0][this.state.timelineEventTypeId.toString()].sample;
      } else {
        return null;
      }
    }
  },

  timelineEventTypeIdForSelect: function () {
    if (this.state.timelineEventTypeId == null) {
      return '';
    } else {
      return this.state.timelineEventTypeId.toString();
    }
  },

  render: function () {
    return (
      <div>
        <TimelineBuilderTextArea showError={ this.state.showDescriptionError } resetErrorsCB={ this.resetErrors }
                                 placeholder={ this.sampleText() }/>

        { this.hasAttachments() &&
        <TimelineBuilderAttachments attachments={ this.attachments() } removeAttachmentCB={ this.removeAttachment }/>
        }

        <TimelineBuilderAttachmentForm currentForm={ this.currentForm() } previousForm={ this.state.previousForm }
                                       addAttachmentCB={ this.addData } selectedDate={ this.state.date }/>

        <TimelineBuilderActionBar formClickedCB={ this.toggleForm } currentForm={ this.currentForm() }
                                  submitCB={ this.submit } timelineEventTypes={ this.props.timelineEventTypes }
                                  addDataCB={ this.addData } coverImage={ this.state.coverImage }
                                  imageButtonKey={ this.state.imageButtonKey } selectedDate={ this.state.date }
                                  submissionProgress={ this.state.submissionProgress }
                                  attachmentAllowed={ this.attachmentAllowed() }
                                  showDateError={ this.state.showDateError } resetErrorsCB={ this.resetErrors }
                                  showEventTypeError={this.state.showEventTypeError}
                                  timelineEventTypeId={ this.timelineEventTypeIdForSelect() }
                                  hasSubmissionError={ this.state.hasSubmissionError }/>
      </div>
    )
  }
});
