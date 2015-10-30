var LinkEditor = React.createClass({
  propTypes: {
    linksJSON: React.PropTypes.string
  },
  render: function() {
    var links = JSON.parse(this.props.linksJSON);
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
            { links && links.length < 3 ? (<button className="btn btn-success" >Add Link</button>) : (null) }
          </div>
        </div>
        <LinkForm></LinkForm>
      </div>
    );
  }
});
