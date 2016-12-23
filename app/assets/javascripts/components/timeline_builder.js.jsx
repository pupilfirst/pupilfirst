const TimelineBuilder = React.createClass({
  propTypes: {
    timelineEventTypes: React.PropTypes.object
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
      timeline_event_type_id: null,
      submissionProgress: null
    }
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

  addData: function (type, properties) {
    if (type == 'link') {
      this.setState({links: this.state.links.concat([properties])});
      this.toggleForm('link')
    } else if (type == 'file') {
      let updatedFiles = $.extend(true, {}, this.state.files);
      updatedFiles[properties.identifier] = {title: properties.title, visibility: properties.visibility};
      this.setState({files: updatedFiles});
      this.toggleForm('file')
    } else if (type == 'cover') {
      // The key for image button is regenerated to ensure the button component is regenerated.
      this.setState({coverImage: {title: 'Cover Image'}, imageButtonKey: this.generateKey()});
    } else if (type == 'date') {
      this.setState({date: properties.value});
    } else if (type == 'timeline_event_type') {
      this.setState({timeline_event_type_id: properties.id});
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
    // TODO: Run presence validations.
    // TODO: Create form and submit it with AJAX.

    let form = $('.timeline-builder-hidden-form');
    let formData = new FormData(form[0]);

    let description = $('.js-timeline-builder__textarea').val();

    formData.append('timeline_event[description]', description);
    formData.append('timeline_event[event_on]', this.state.date);
    formData.append('timeline_event[links]', JSON.stringify(this.state.links));
    formData.append('timeline_event[files_metadata]', JSON.stringify(this.state.files));
    formData.append('timeline_event[timeline_event_type_id]', this.state.timeline_event_type_id);

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
  },

  xhrCallback: function () {
    let myXhr = $.ajaxSettings.xhr();

    if (myXhr.upload != null) { // Check if upload property exists.
      // For handling the progress of the upload.
      myXhr.upload.addEventListener('progress', this.handleSubmissionProgress, false);
    }

    return myXhr;
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
    console.warn("handleSubmissionError() has not been implemented!");
  },

  handleSubmissionComplete: function () {
    console.warn("handleSubmissionComplete() has not been implemented!")
  },

  render: function () {
    return (
      <div>
        <TimelineBuilderTextArea/>

        { this.hasAttachments() &&
        <TimelineBuilderAttachments attachments={ this.attachments() } removeAttachmentCB={ this.removeAttachment }/>
        }

        <TimelineBuilderAttachmentForm currentForm={ this.currentForm() } previousForm={ this.state.previousForm }
                                       addAttachmentCB={ this.addData } selectedDate={ this.state.date }/>
        <TimelineBuilderActionBar formClickedCB={ this.toggleForm } currentForm={ this.currentForm() }
                                  submitCB={ this.submit } timelineEventTypes={ this.props.timelineEventTypes }
                                  addDataCB={ this.addData } coverImage={ this.state.coverImage }
                                  imageButtonKey={ this.state.imageButtonKey } selectedDate={ this.state.date }
                                  submissionProgress={ this.state.submissionProgress }/>
      </div>
    )
  }
});
