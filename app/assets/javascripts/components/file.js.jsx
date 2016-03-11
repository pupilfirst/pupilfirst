var File = React.createClass({
  propTypes: {
    title: React.PropTypes.string.isRequired,
    identifier: React.PropTypes.string.isRequired,
    private: React.PropTypes.bool.isRequired,
    persisted: React.PropTypes.bool,
    deleteFileCB: React.PropTypes.func,
    markFileForDeletionCB: React.PropTypes.func,
    markedForDeletion: React.PropTypes.bool
  },

  deleteFile: function () {
    if (confirm('Are you sure you want to delete this file?')) {
      // Remove the corresponding input element.
      $('#timeline_event_file_' + this.props.identifier).remove();

      // Handle passed all the way from attachments editor.
      this.props.deleteFileCB(this.props.index);
    }
  },

  markFileForDeletion: function () {
    if (confirm('This file will be marked for deletion, and removed when you submit changes to timeline event. Continue?')) {
      this.props.markFileForDeletionCB(this.props.index);
    }
  },

  showDeleteButton: function () {
    return !this.props.markedForDeletion;
  },

  fileIconClasses: function() {
    if (this.props.markedForDeletion) {
      return 'fa fa-trash';
    } else if (this.props.private) {
      return 'fa fa-user-secret';
    } else {
      return 'fa fa-file-o';
    }
  },

  render: function () {
    return (
      <li className="list-group-item">
        <i className={ this.fileIconClasses() }/>
        &nbsp;
        <span className={this.props.markedForDeletion ? 'strike' : ''}>{ this.props.title }</span>
        <div className="pull-right">
          { this.showDeleteButton() &&
          <a className="margin-right-10" onClick={this.props.persisted ? this.markFileForDeletion : this.deleteFile}>Delete</a>
          }
          { this.props.markedForDeletion &&
          <em>Marked for Deletion</em>
          }
        </div>
      </li>
    );
  }
});
