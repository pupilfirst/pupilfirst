var AATimelineEventLinksEditor = React.createClass({
  getInitialState: function () {
    return {
      links: (this.props.linksJSON.length > 0 ? JSON.parse(this.props.linksJSON) : []),
      showLinkForm: false,
    };
  },

  addLinksClicked: function () {
    this.setState({showLinkForm: true, showFileForm: false});
  },

  addNewLink: function (newLink) {
    var presentLinks = this.state.links;
    presentLinks.push(newLink);
    this.setState({links: presentLinks, showLinkForm: false});
  },

  attachmentsLimitNotReached: function () {
    var totalAttachments = this.state.links.length;
    return totalAttachments < 3;
  },

  showAddLinkButton: function () {
    return this.attachmentsLimitNotReached() && !this.state.showLinkForm;
  },

  deleteLink: function (i) {
    var updatedLinks = this.state.links;
    updatedLinks.splice(i, 1);
    this.setState({links: updatedLinks});
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
        <AALinkList links={ this.state.links } deleteLinkCB={ this.deleteLink }
                    editLinkClickedCB={ this.editLinkClicked }/>

        { this.showAddLinkButton() &&
        <a onClick={this.addLinksClicked} className="button">
          <i className="fa fa-plus"/> Add a link
        </a>
        }

        { this.state.showLinkForm &&
        <AALinkForm linkAddedCB={this.addNewLink} editLinkCB={ this.editLink }
                    link={ this.state.linkToEdit }/>
        }
      </div>
    );
  }
});
