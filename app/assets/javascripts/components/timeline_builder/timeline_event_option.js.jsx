const TimelineBuilderTimelineEventOption = React.createClass({
  propTypes: {
    timelineEventId: React.PropTypes.string,
    timelineEvent: React.PropTypes.object
  },

  render: function () {
    return (
      <option value={this.props.timelineEventId}>{this.props.timelineEvent.title}</option>
    )
  }
});
