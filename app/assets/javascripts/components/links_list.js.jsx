var LinkList = React.createClass({
  propTypes: {
    links: React.PropTypes.arrayOf(React.PropTypes.object)
  },

  getInitialState: function() {
    return {links: this.props.links};
  },

  render: function() {
    return (
      <ul className="list-group">
        { this.state.links.map(function(link,i){
          return (<Link title={link.title} url={link.url} private={link.private} key={i}></Link>)
        })}
      </ul>
    );
  }
});
