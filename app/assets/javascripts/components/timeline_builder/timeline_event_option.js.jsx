const TimelineBuilderTimelineEventOption = createReactClass({
  propTypes: {
    timelineEventId: PropTypes.string,
    timelineEvent: PropTypes.object
  },

  render: function() {
    return (
      <option value={this.props.timelineEventId}>
        {this.props.timelineEvent.title}
      </option>
    );
  }
});
