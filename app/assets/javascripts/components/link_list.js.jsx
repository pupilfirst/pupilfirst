var LinkList = React.createClass({
  propTypes: {
    linksJSON: React.PropTypes.string
  },

  render: function() {
    var links = JSON.parse(this.props.linksJSON);
    var viewList=[];
    for (var i = 0; i < links.length; i++) {
      viewList.push(<Link title={links[i].title} url={links[i].url} private={links[i].private}></Link>);
    }
    return (
          <ul className="list-group">
            { viewList }
          </ul>
    );
  }
});
