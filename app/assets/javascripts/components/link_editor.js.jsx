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
          { links && links.length > 0 ?
          (
            <div className="col-sm-offset-2 col-sm-10">
              <LinkList linksJSON={ this.props.linksJSON }></LinkList>
            </div>
          )
          :
          (
            <div className="col-sm-offset-2 col-sm-10">
              <p>No links added!</p>
            </div>
          )
          }
        </div>
        <LinkForm></LinkForm>
      </div>
    );
  }
});
