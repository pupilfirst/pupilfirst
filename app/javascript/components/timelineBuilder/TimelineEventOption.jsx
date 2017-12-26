import React from "react";
import PropTypes from "prop-types";

export default class TimelineEventOption extends React.Component {
  render() {
    return (
      <option value={this.props.timelineEventId}>
        {this.props.timelineEvent.title}
      </option>
    );
  }
}

TimelineEventOption.propTypes = {
  timelineEventId: PropTypes.string,
  timelineEvent: PropTypes.object
};
