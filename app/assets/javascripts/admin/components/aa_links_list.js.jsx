var AALinkList = React.createClass({
  propTypes: {
    links: React.PropTypes.arrayOf(React.PropTypes.object)
  },

  getInitialState: function () {
    return {links: this.props.links};
  },

  componentDidUpdate: function () {
    //always copy latest links to the hidden field, trigger change to update the link tab's title
    $('#timeline_event_serialized_links').val(JSON.stringify(this.state.links)).trigger('change');
  },

  render: function () {
    if (this.state.links.length > 0) {
      return (
        <div className="attributes_table">
          <table>
            <tbody>
            { this.state.links.map(function (link, i) {
              return (<AALink title={link.title} url={link.url} private={link.private} index={i}
                              editLinkClickedCB={this.props.editLinkClickedCB} deleteLinkCB={this.props.deleteLinkCB}
                              key={link.title+link.url}/>);
            }.bind(this))
            }
            </tbody>
          </table>
        </div>
      )
    } else {
      return <div></div>
    }
  }
});
