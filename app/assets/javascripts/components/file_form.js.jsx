var FileForm = React.createClass({
  getInitialState: function () {
    return {fileError: false};
  },

  saveFile: function () {
    var fileInput = $('#timeline-event-file-input');
    var fileName = fileInput.val().split(/(\\|\/)/g).pop();
    var filePrivate = $('#timeline-event-file-private').prop('checked');

    if (fileName.length > 0) {
      // Move the input to parent form, and set correct attributes, so that file can be uploaded on form submit.
      var timelineEventForm = $('#new_timeline_event');

      if (timelineEventForm.length == 0) {
        timelineEventForm = $('form.edit_timeline_event');
      }

      fileInput.removeAttr('data-reactid');
      fileInput.attr('id', 'timeline_event_file_' + this.props.fileIdentifier);
      fileInput.attr('name', 'timeline_event[files][' + this.props.fileIdentifier + ']');
      fileInput.addClass('hide');
      fileInput.appendTo(timelineEventForm);

      // Let attachments editor know so it can propagate changes.
      this.props.fileAddedCB({
        name: fileName,
        private: filePrivate,
        identifier: this.props.fileIdentifier,
        persisted: false
      });
    } else {
      this.setState({fileError: true});
    }
  },

  formClasses: function () {
    if (this.state.fileError) {
      return 'form-group has-error';
    } else {
      return 'form-group';
    }
  },

  render: function () {
    return (
      <div>
        <h4>Add File</h4>
        <div className="form-horizontal">
          <div className={ this.formClasses() }>
            <div className="col-sm-offset-2 col-sm-10">
              <input type="file" id="timeline-event-file-input"/>
              {
                this.state.fileError &&
                <p className="help-block">Please pick a file!</p>
              }
            </div>
          </div>

          <div className="form-group">
            <div className="col-sm-offset-2 col-sm-10">
              <div className="checkbox">
                <label>
                  <input id="timeline-event-file-private" type="checkbox" name="file-private"/>
                  Hide from public?
                </label>
              </div>
            </div>
          </div>

          <div className="form-group margin-top-20">
            <div className="col-sm-offset-2 col-sm-10">
              <button onClick={this.saveFile} className="btn btn-success"><i className="fa fa-plus"></i> Save File
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }
});
