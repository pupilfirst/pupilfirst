var LinkEditor = React.createClass({
  propTypes: {
    linksJSON: React.PropTypes.string
  },

  getInitialState: function() {
    return {links: JSON.parse(this.props.linksJSON), showLinkForm: false};
  },

  addLinksClicked: function() {
    this.setState({showLinkForm: true});
  },

  newLinkAdded: function(title, url, private) {
    var newLink = {"title": title,"url": url,"private": private};
    var presentLinks = this.state.links;
    presentLinks.push(newLink);
    this.setState({links: presentLinks, showLinkForm: false});
  },

  showAddButton: function() {
    return this.state.links.length < 3 && !this.state.showLinkForm;
  },

  render: function() {
    var links = this.state.links;
    return (
      <div>
        <h4>Current Links</h4>
        <div className="row">
          <div className="col-sm-offset-2 col-sm-10">
            { links.length > 0 ?
            (
              <ul className="list-group">
                { links.map(function(link,i){
                  return (<Link title={link.title} url={link.url} private={link.private} key={i}></Link>)
                })}
              </ul>
            )
            :
            (
              <p>No links added!</p>
            )
            }
            { this.showAddButton() ? (<button onClick={this.addLinksClicked} className="btn btn-default" ><i className="fa fa-plus"></i> Add Links</button>) : (null) }
          </div>
        </div>
        { this.state.showLinkForm ? (<LinkForm linkAddedCallBack={this.newLinkAdded}></LinkForm>) : null }
      </div>
    );
  }
});
