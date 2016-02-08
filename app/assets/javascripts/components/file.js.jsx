var File = React.createClass({
  propTypes: {
    name: React.PropTypes.string,
    identifier: React.PropTypes.string,
    private: React.PropTypes.bool
  },

  deleteFile: function () {
    // Remove the corresponding input element.
    $('#timeline_event_file_' + this.props.identifier).remove();

    // Handle passed all the way from attachments editor.
    this.props.deleteFileCB(this.props.index);
  },

  render: function () {
    return (
      <li className="list-group-item">
        <i className={ this.props.private ? 'fa fa-user-secret' : 'fa fa-file-o'}/>
        &nbsp;{ this.props.name }
        <div className="pull-right">
          <a className="margin-right-10" onClick={this.deleteFile}>Delete</a>
        </div>
      </li>
    );
  }
});
