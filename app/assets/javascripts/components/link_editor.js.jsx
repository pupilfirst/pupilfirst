var LinkEditor = React.createClass({
  propTypes: {
    linksJSON: React.PropTypes.string
  },
  render: function() {
    return (
      <div>
        <h4>Current Links</h4>
        <div className="row">
          <div className="col-sm-offset-2 col-sm-10">
            <LinkList linksJSON={ this.props.linksJSON }></LinkList>
          </div>
        </div>
      </div>
    );
  }
});
