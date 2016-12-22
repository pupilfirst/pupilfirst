const TimelineBuilderFileForm = React.createClass({
  propTypes: {
    addAttachmentCB: React.PropTypes.func
  },

  getInitialState: function () {
    return {identifier: this.generateIdentifier()}
  },

  fileSubmit: function (event) {
    event.preventDefault();

    // TODO: Add validations.

    this.props.addAttachmentCB('file', {
      title: $('.js-file-title').val(),
      visibility: $('.js-file-visibility').val(),
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
    originalInput.attr('name', this.inputName());
  },

  generateIdentifier: function () {
    return '' + (new Date).getTime();
  },

  regenerateIdentifier: function () {
    // The identifier for the next file = 0 + number of files already present.
    return this.setState({identifier: this.generateIdentifier()});
  },

  inputName: function () {
    return "timeline_event[files][" + this.state.identifier + "]"
  },

  render: function () {
    return (
      <form className="form-inline timeline-builder__attachment-form">
        <div className="form-group timeline-builder__form-group">
          <label className="sr-only" htmlFor="fileTitle">File Title</label>
          <input className="form-control file-title js-file-title" type="text" placeholder="Title"/>
        </div>
        <TimelineBuilderFilePicker key={ this.state.identifier }/>
        <div className="form-group timeline-builder__form-group timeline-builder__visibility-option-group">
          <select className="form-control visibility-option js-file-visibility">
            <option value="public">Public</option>
            <option value="private">Private</option>
          </select>
        </div>
        <button type="submit" className="btn btn-secondary" onClick={ this.fileSubmit }>
          <i className="fa fa-check"/>
        </button>
      </form>
    )
  }
});
