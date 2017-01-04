const TimelineBuilderAttachment = React.createClass({
  propTypes: {
    attachment: React.PropTypes.object,
    removeAttachmentCB: React.PropTypes.func
  },

  iconClasses: function () {
    let baseClass = "timeline-builder__attachment-icon";

    switch (this.props.attachment.type) {
      case 'cover':
        return baseClass + ' fa fa-picture-o';
      case 'file':
        return baseClass + ' fa fa-file-text-o';
      case 'link':
        return baseClass + ' fa fa-link';
    }
  },

  removeAttachment: function () {
    this.props.removeAttachmentCB(this.props.attachment.type, this.props.attachment.index);
  },

  render: function () {
    return (
      <div className="timeline-builder__attachment pull-xs-left m-r-1 m-t-1">
        { this.props.attachment.private &&
        <div className="timeline-builder__attachment-private-indicator">
          <i className="fa fa-lock"/>
        </div>
        }
        <i className={ this.iconClasses() }/>
        <span className="timeline-builder__attachment-title">{ this.props.attachment.title }</span>
        <button type="button" className="close timeline-builder__remove-attachment" onClick={ this.removeAttachment }>
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
    )
  }
});
