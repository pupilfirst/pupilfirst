const TimelineBuilderAttachment = React.createClass({
  propTypes: {
    attachment: React.PropTypes.object
  },

  iconClasses: function () {
    switch (this.props.attachment.type) {
      case 'cover':
        return 'fa fa-image-o';
      case 'file':
        return 'fa fa-file-text-o';
      case 'link':
        return 'fa fa-link';
    }
  },

  render: function () {
    return (
      <div className="attachment pull-xs-left m-r-1 m-t-1">
        <i className={ this.iconClasses() }/>
        <span className="attachment-title">{ this.props.attachment.title }</span>
        <button type="button" className="close remove-attachment">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
    )
  }
});
