const TimelineBuilderFileForm = React.createClass({
  propTypes: {
    addAttachmentCB: React.PropTypes.func
  },

  getInitialState: function () {
    return {identifier: 0}
  },

  fileSubmit: function (event) {
    event.preventDefault();

    // TODO: Add validations.

    this.props.addAttachmentCB('file', {
      title: $('.js-file-title').val(),
      visibility: $('.js-link-visibility').val(),
      identifier: this.state.identifier
    });

    this.copyFileInputToHiddenForm();
    this.regenerateIdentifier();

    setTimeout(this.clearForm, 500);
  },

  clearForm: function () {
    $('.js-file-title').val('');
    $('.js-file-visibility').val('public');
  },

  copyFileInputToHiddenForm: function () {
    let originalInput = $('.js-attachment-file');
    let clonedInput = originalInput.clone();
    let hiddenForm = $('.timeline-builder-hidden-form');

    // Place a clone after the original input, and move the original into the hidden form.
    originalInput.after(clonedInput).appendTo(hiddenForm);

    // Prep the original input for submission.
    originalInput.removeAttr('id class');
    originalInput.addClass('js-hidden-file');
    originalInput.attr('name', this.inputName());
  },

  regenerateIdentifier: function () {
    // The identifier for the next file = 0 + number of files already present.
    this.setState({identifier: $('.js-hidden-file').length});
  },

  inputName: function () {
    return "timeline_event[files][" + this.state.identifier + "]"
  },

  render: function () {
    return (
      <form className="form-inline attachment-form">
        <div className="form-group file-title-group">
          <label className="sr-only" htmlFor="fileTitle">File Title</label>
          <input className="form-control file-title js-file-title" type="text" placeholder="Title"/>
        </div>
        <TimelineBuilderFilePicker key={ this.state.identifier }/>
        <div className="form-group visibility-option-group">
          <select className="form-control visibility-option js-file-visibility">
            <option>Public</option>
            <option>Private</option>
          </select>
        </div>
        <button type="submit" className="btn btn-secondary" onClick={ this.fileSubmit }>
          <i className="fa fa-check"/>
        </button>
      </form>
    )
  }
});
