var LinkList = React.createClass({
  propTypes: {
    linksJSON: React.PropTypes.string
  },

  render: function() {
    var links = JSON.parse(this.props.linksJSON);
    return (
          <ul className="list-group">
            { links.map(function(link,i){
              return (<Link title={link.title} url={link.url} private={links.private} key={i}></Link>)
            })}
          </ul>
    );
  }
});
