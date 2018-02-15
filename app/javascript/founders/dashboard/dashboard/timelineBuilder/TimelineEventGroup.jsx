import React from "react";
import PropTypes from "prop-types";
import TimelineEventOption from "./TimelineEventOption";

export default class TimelineEventGroup extends React.Component {
  render() {
    return (
      <optgroup label={this.props.role}>
        {Object.keys(this.props.timelineEvents).map(function(
          timelineEventId,
          index
        ) {
          return (
            <TimelineEventOption
              timelineEventId={timelineEventId}
              timelineEvent={this.props.timelineEvents[timelineEventId]}
              key={index}
            />
          );
        },
        this)}
      </optgroup>
    );
  }
}

TimelineEventGroup.propTypes = {
  role: PropTypes.string,
  timelineEvents: PropTypes.object
};
