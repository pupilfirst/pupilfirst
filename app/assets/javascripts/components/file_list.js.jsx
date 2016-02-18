var FileList = React.createClass({
  propTypes: {
    files: React.PropTypes.arrayOf(React.PropTypes.object)
  },

  getInitialState: function () {
    return {files: this.props.files};
  },

  writeFileJSON: function () {
    // Always copy latest files metadata to the hidden field, trigger change to update the file tab's title.
    $('#timeline_event_files_metadata').val(JSON.stringify(this.state.files)).trigger('change');
  },

  componentDidMount: function () {
    this.writeFileJSON();
  },

  componentDidUpdate: function () {
    this.writeFileJSON();
  },

  render: function () {
    if (this.state.files.length > 0) {
      return (
        <ul className="list-group">
          { this.state.files.map(function (file, i) {
            return (<File name={file.name} key={file.identifier} identifier={file.identifier} private={file.private}
                          markedForDeletion={!!file['delete']} persisted={file.persisted} index={i}
                          deleteFileCB={this.props.deleteFileCB}
                          markFileForDeletionCB={this.props.markFileForDeletionCB}/>);
          }.bind(this))
          }
        </ul>
      )
    } else {
      return <div/>;
    }
  }
});
