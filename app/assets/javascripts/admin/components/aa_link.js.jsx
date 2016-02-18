var AALink = React.createClass({
  propTypes: {
    title: React.PropTypes.string,
    url: React.PropTypes.string,
    private: React.PropTypes.bool
  },

  deleteLink: function () {
    //handle passed all the way from linkEditor
    this.props.deleteLinkCB(this.props.index);
  },

  editLinkClicked: function () {
    //handle passed all the way from linkEditor
    this.props.editLinkClickedCB(this.props.index);
  },

  render: function () {
    return (
      <tr className="row">
        <th>
          <i className={ this.props.private ? 'fa fa-user-secret' : 'fa fa-globe'}/>
          &nbsp;{ this.props.title }
        </th>
        <td>
          <a href={ this.props.url } target="_blank">{ this.props.url }</a>
          &nbsp;(<a onClick={this.editLinkClicked}>Edit</a> / <a onClick={this.deleteLink}>Delete</a>)
        </td>
      </tr>
    );
  }
});
