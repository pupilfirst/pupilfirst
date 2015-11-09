var LinkEditor = React.createClass({
  getInitialState: function() {
    return {links: ( this.props.linksJSON.length>0 ? JSON.parse(this.props.linksJSON) : []), showLinkForm: false};
  },

  addLinksClicked: function() {
    this.setState({showLinkForm: true});
  },

  addNewLink: function(newLink) {
    var presentLinks = this.state.links;
    presentLinks.push(newLink);
    this.setState({links: presentLinks, showLinkForm: false});
  },

  showAddButton: function() {
    return this.state.links.length < 3 && !this.state.showLinkForm;
  },

  deleteLink: function (i) {
    var updatedLinks = this.state.links;
    updatedLinks.splice(i,1);
    this.setState({links: updatedLinks});
  },

  editLinkClicked: function(i) {
    //clone the object to a new one, else it will be passed by reference
    var linkToEdit = $.extend({},this.state.links[i]);
    linkToEdit.index = i;
    this.setState({linkToEdit: linkToEdit, showLinkForm: true});
  },

  editLink: function(link) {
    var presentLinks = this.state.links;
    presentLinks[link.index] = {"title": link.title, "url": link.url, "private": link.private};
    this.setState({links: presentLinks, showLinkForm: false, linkToEdit: null});
  },


  render: function() {
    var links = this.state.links;
    return (
      <div>
        <h4>Current Links</h4>
        <div className="row">
          <div className="col-sm-offset-2 col-sm-10">
            <LinkList links={ links } deleteLinkCB={ this.deleteLink } editLinkClickedCB={ this.editLinkClicked } ></LinkList>
            { this.showAddButton() ? (<button onClick={this.addLinksClicked} className="btn btn-default" ><i className="fa fa-plus"></i> Add Links</button>) : (null) }
          </div>
        </div>
        { this.state.showLinkForm ? (<LinkForm linkAddedCB={this.addNewLink} editLinkCB={ this.editLink } link={ this.state.linkToEdit }></LinkForm>) : null }
      </div>
    );
  }
});
