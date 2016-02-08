var TimelineEventAttachmentsEditor = React.createClass({
  getInitialState: function () {
    return {
      links: (this.props.linksJSON.length > 0 ? JSON.parse(this.props.linksJSON) : []),
      //files: (this.props.filesJSON.length > 0 ? JSON.parse(this.props.filesJSON) : []),
      files: [],
      showLinkForm: false,
      showFileForm: false
    };
  },

  addLinksClicked: function () {
    this.setState({showLinkForm: true, showFileForm: false});
  },

  addFileClicked: function () {
    this.setState({showFileForm: true, showLinkForm: false});
  },

  addNewLink: function (newLink) {
    var presentLinks = this.state.links;
    presentLinks.push(newLink);
    this.setState({links: presentLinks, showLinkForm: false});
  },

  addNewFile: function (newFile) {
    var presentFiles = this.state.files;
    presentFiles.push(newFile);
    this.setState({files: presentFiles, showFileForm: false});
  },

  newFileIdentifier: function () {
    return '' + (new Date).getTime();
  },

  showAddLinkButton: function () {
    return this.state.links.length < 3 && !this.state.showLinkForm;
  },

  showAddFileButton: function () {
    return !this.state.showFileForm
  },

  deleteLink: function (i) {
    var updatedLinks = this.state.links;
    updatedLinks.splice(i, 1);
    this.setState({links: updatedLinks});
  },

  deleteFile: function (index) {
    var updatedFiles = this.state.files;
    updatedFiles.splice(index, 1);
    this.setState({files: updatedFiles});
  },

  editLinkClicked: function (i) {
    //clone the object to a new one, else it will be passed by reference
    var linkToEdit = $.extend({}, this.state.links[i]);
    linkToEdit.index = i;
    this.setState({linkToEdit: linkToEdit, showLinkForm: true});
  },

  editLink: function (link) {
    var presentLinks = this.state.links;
    presentLinks[link.index] = {"title": link.title, "url": link.url, "private": link.private};
    this.setState({links: presentLinks, showLinkForm: false, linkToEdit: null});
  },

  render: function () {
    return (
      <div>
        <h4>Links and Files</h4>
        <div className="row">
          <div className="col-sm-offset-2 col-sm-10">
            <LinkList links={ this.state.links } deleteLinkCB={ this.deleteLink }
                      editLinkClickedCB={ this.editLinkClicked }/>

            <FileList files={ this.state.files } deleteFileCB={ this.deleteFile }/>

            { this.showAddLinkButton() &&
            <button onClick={this.addLinksClicked} className="btn btn-default margin-right-5">
              <i className="fa fa-plus"/> Add a link
            </button>
            }

            { this.showAddFileButton() &&
            <button onClick={this.addFileClicked} className="btn btn-default">
              <i className="fa fa-plus"/> Attach a file
            </button>
            }
          </div>
        </div>

        { this.state.showLinkForm &&
        <LinkForm linkAddedCB={this.addNewLink} editLinkCB={ this.editLink }
                  link={ this.state.linkToEdit }/>
        }

        { this.state.showFileForm &&
        <FileForm fileAddedCB={this.addNewFile} fileIdentifier={this.newFileIdentifier()}/>
        }
      </div>
    );
  }
});
