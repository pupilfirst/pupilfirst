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
          <button className="btn btn-default btn-xs margin-right-10" onClick={this.editLinkClicked} >Edit</button>
          <button className="btn btn-danger btn-xs" onClick={this.deleteLink} >Delete</button>
        </div>
        <p className="grey-text margin-bottom-0">{ this.props.url }</p>
      </li>
    );
  }
});
