const TimelineBuilderTimelineEventGroup = React.createClass({
  propTypes: {
    role: React.PropTypes.string,
    timelineEvents: React.PropTypes.object
  },

  render: function () {
    return (
      <optgroup label={ this.props.role }>
        { Object.keys(this.props.timelineEvents).map(function (timelineEventId, index) {
          return <TimelineBuilderTimelineEventOption timelineEventId={ timelineEventId }
                                                     timelineEvent={ this.props.timelineEvents[timelineEventId] }
                                                     key={ index }/>
        }, this)}
      </optgroup>
    )
  }
});
