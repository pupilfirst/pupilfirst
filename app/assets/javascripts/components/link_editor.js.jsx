var LinkEditor = React.createClass({
  propTypes: {
    linksJSON: React.PropTypes.string
  },

  getInitialState: function() {
    return {links: this.props.linksJSON, showLinkForm: false, showAddButton:true};
  },

  addLinksClicked: function() {
    console.log('Add link clicked');
    this.setState({showLinkForm: true, showAddButton: false})
  },

  render: function() {
    var links = JSON.parse(this.state.links);
    return (
      <div>
        <h4>Current Links</h4>
        <div className="row">
          <div className="col-sm-offset-2 col-sm-10">
            { links && links.length > 0 ?
            (
              <ul className="list-group">
                { links.map(function(link,i){
                  return (<Link title={link.title} url={link.url} private={links.private} key={i}></Link>)
                })}
              </ul>
            )
            :
            (
              <p>No links added!</p>
            )
            }
            { this.state.showAddButton && links && links.length < 3 ? (<button onClick={this.addLinksClicked} className="btn btn-default" ><i className="fa fa-plus"></i> Add More Links</button>) : (null) }
          </div>
        </div>
        { this.state.showLinkForm ? (<LinkForm></LinkForm>) : null }
      </div>
    );
  }
});
