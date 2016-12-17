const TimelineBuilder = React.createClass({
  getInitialState: function () {
    return {
      links: [],
      files: [],
      cover_image: null,
      showLinkForm: false,
      showFileForm: false,
      previousForm: null
    }
  },

  toggleForm: function (type) {
    let previousForm = this.currentForm();

    if (type == 'link') {
      let newState = !this.state.showLinkForm;
      this.setState({showLinkForm: newState, showFileForm: false, previousForm: previousForm});
    } else {
      let newState = !this.state.showFileForm;
      this.setState({showLinkForm: false, showFileForm: newState, previousForm: previousForm});
    }
  },

  currentForm: function () {
    if (this.state.showLinkForm) {
      return 'link'
    } else if (this.state.showFileForm) {
      return 'file'
    } else {
      return null
    }
  },

  hasAttachments: function () {
    return this.state.links.length > 0 || this.state.files.length > 0 || this.state.cover_image != null
  },

  submit: function (event) {
    // TODO: Run presence validations.
    // TODO: Create form and submit it with AJAX.

    // Block the submit from going through.
    event.preventDefault();

    let form = $('.timeline-builder-hidden-form');
    let formData = new FormData(form[0]);

    let description = $('.timeline-builder-textarea').val();

    formData.append('timeline_event[description]', description);

    // Submit form data using AJAX and set a progress handler function.
    $.ajax({
      url: form.attr('action'),
      type: form.attr('method'),

      xhr: function () {
        let myXhr = $.ajaxSettings.xhr();

        // if (myXhr.upload) { // Check if upload property exists.
        //   // For handling the progress of the upload.
        //   myXhr.upload.addEventListener('progress', progressHandlingFunction, false);
        // }

        return myXhr;
      },

      // Ajax events.
      // beforeSend: beforeSendHandler,
      // success: completeHandler,
      // error: errorHandler,

      // Form data
      data: formData,

      // Options to tell jQuery not to process data or worry about content-type.
      cache: false,
      contentType: false,
      processData: false
    });
  },

  render: function () {
    return (
      <div>
        <TimelineBuilderTextArea/>

        { this.hasAttachments() &&
        <TimelineBuilderAttachments/>
        }

        <TimelineBuilderAttachmentForm currentForm={ this.currentForm() } previousForm={ this.state.previousForm }/>
        <TimelineBuilderActionBar formClickedCB={ this.toggleForm } currentForm={ this.currentForm() }
                                  submitCB={ this.submit }/>
      </div>
    )
  }
});
