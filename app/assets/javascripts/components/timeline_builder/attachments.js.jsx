const TimelineBuilderAttachments = React.createClass({
  propTypes: {
    attachments: React.PropTypes.array,
    removeAttachmentCB: React.PropTypes.func
  },

  render: function () {
    return (
      <div className="timeline-builder__attachments-container clearfix">
        { this.props.attachments.map(function (attachment, index) {
          return <TimelineBuilderAttachment attachment={ attachment } key={ index } removeAttachmentCB={ this.props.removeAttachmentCB }/>
        }, this)}
      </div>
    )
  }
});
