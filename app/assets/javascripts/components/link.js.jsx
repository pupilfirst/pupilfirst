var Link = React.createClass({
  propTypes: {
    title: React.PropTypes.string,
    url: React.PropTypes.string,
    private: React.PropTypes.bool
  },

  deleteLink: function(){
    //handle passed all the way from linkEditor
    this.props.deleteLinkCB(this.props.index);
  },

  editLinkClicked: function(){
    //handle passed all the way from linkEditor
    this.props.editLinkClickedCB(this.props.index);
  },

  render: function() {
    return (
      <li className="list-group-item">
        <a href={ this.props.url } target="_blank">
          <i className={ this.props.private ? 'fa fa-user-secret' : 'fa fa-globe'}></i>
          &nbsp;{ this.props.title }
        </a>
        <div className="pull-right">
          <a className="margin-right-10" onClick={this.editLinkClicked} >Edit</a>
          <a onClick={this.deleteLink} >Delete</a>
        </div>
        <p className="grey-text margin-bottom-0">{ this.props.url }</p>
      </li>
          );
        }
});
