const TimelineBuilderAttachments = createReactClass({
  propTypes: {
    attachments: PropTypes.array,
    removeAttachmentCB: PropTypes.func
  },

  render: function() {
    return (
      <div className="timeline-builder__attachments-container clearfix">
        {this.props.attachments.map(function(attachment, index) {
          return (
            <TimelineBuilderAttachment
              attachment={attachment}
              key={index}
              removeAttachmentCB={this.props.removeAttachmentCB}
            />
          );
        }, this)}
      </div>
    );
  }
});
