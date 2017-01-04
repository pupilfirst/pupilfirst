const TimelineBuilderFileForm = React.createClass({
  propTypes: {
    addAttachmentCB: React.PropTypes.func
  },

  getInitialState: function () {
    return {
      identifier: this.generateIdentifier(),
      titleError: false,
      fileMissingError: false,
      fileSizeError: false
    }
  },

  fileSubmit: function (event) {
    event.preventDefault();
    if (this.validate()) {
      this.storeFile();
      setTimeout(this.clearForm, 500);
    }
  },

  clearForm: function () {
    $('.js-file-title').val('');
    $('.js-file-visibility').val('public');
    this.setState({
      titleError: false,
      fileMissingError: false,
      fileSizeError: false
    });
  },

  storeFile: function () {
    this.props.addAttachmentCB('file', {
      title: $('.js-file-title').val(),
      private: $('.js-file-visibility').val() == 'private',
      identifier: this.state.identifier
    });

    this.copyFileInputToHiddenForm();
    this.regenerateIdentifier();
  },

  copyFileInputToHiddenForm: function () {
    let originalInput = $('.js-attachment-file');
    let clonedInput = originalInput.clone();
    let hiddenForm = $('.timeline-builder-hidden-form');

    // Place a clone after the original input, and move the original into the hidden form.
    originalInput.after(clonedInput).appendTo(hiddenForm);

    // Prep the original input for submission.
    originalInput.removeAttr('id class');
    originalInput.attr('name', this.inputName());
  },

  generateIdentifier: function () {
    return '' + (new Date).getTime();
  },

  regenerateIdentifier: function () {
    // The identifier for the next file = 0 + number of files already present.
    return this.setState({identifier: this.generateIdentifier()});
  },

  validate: function () {
    let titleError = false;
    let fileMissingError = false;
    let fileSizeError = false;

    if ($('.js-file-title').val().length == 0) {
      titleError = true;
    }

    if ($('.js-attachment-file')[0].files.length == 0) {
      fileMissingError = true;
    } else if ($('.js-attachment-file')[0].files[0].size > 5242880) {
      fileSizeError = true;
    }

    if (titleError || fileMissingError || fileSizeError) {
      this.setState({titleError: titleError, fileMissingError: fileMissingError, fileSizeError: fileSizeError});
      return false;
    }

    return true;
  },

  clearPickerErrors: function () {
    this.setState({fileMissingError: false, fileSizeError: false});
  },

  inputName: function () {
    return "timeline_event[files][" + this.state.identifier + "]"
  },

  titleFormGroupClasses: function () {
    return "form-group timeline-builder__form-group" + (this.state.titleError ? ' has-danger' : '');
  },

  clearTitleError: function () {
    this.setState({titleError: false});
  },

  render: function () {
    return (
      <form className="form-inline timeline-builder__attachment-form">
        <div className={this.titleFormGroupClasses()}>
          <label className="sr-only" htmlFor="timeline-builder__file-title-input">File Title</label>
          <input id="timeline-builder__file-title-input" className="form-control file-title js-file-title" type="text"
                 placeholder="Title" onFocus={ this.clearTitleError }/>
          { this.state.titleError &&
          <div className="form-control-feedback">Enter a valid title!</div>
          }
        </div>
        <TimelineBuilderFilePicker key={ this.state.identifier } fileMissingError={ this.state.fileMissingError }
                                   fileSizeError={ this.state.fileSizeError } clearErrorsCB={ this.clearPickerErrors }/>
        <div className="form-group timeline-builder__form-group timeline-builder__visibility-option-group">
          <label className="sr-only" htmlFor="timeline-builder__file-visibility-select">File Visibility</label>
          <select id="timeline-builder__file-visibility-select"
                  className="form-control timeline-builder__visibility-option js-file-visibility">
            <option value="public">Public</option>
            <option value="private">Private</option>
          </select>
        </div>
        <button type="submit" className="btn btn-secondary text-uppercase timeline-builder__attachment-button"
                onClick={ this.fileSubmit }>
          Add File
        </button>
      </form>
    )
  }
});
