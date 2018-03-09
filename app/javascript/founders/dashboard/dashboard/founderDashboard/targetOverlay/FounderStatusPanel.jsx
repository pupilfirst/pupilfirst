import React from "react";
import PropTypes from "prop-types";
import FounderBubble from "./FounderBubble";

export default class FounderStatusPanel extends React.Component {
  founderStatuses() {
    if (_.isObject(this.props.founderStatuses)) {
      return this.props.founderStatuses;
    } else {
      return this.initialStatuses();
    }
  }

  initialStatuses() {
    return this.props.founderDetails.map(function(founderDetail) {
      return {
        id: founderDetail.founderId,
        status: "loading"
      };
    });
  }

  render() {
    return (
      <div className="founder-dashboard__avatars ml-2">
        {this.founderStatuses().map(founderStatus => {
          const id = founderStatus.id;
          const status = founderStatus.status;
          const founder = _.find(this.props.founderDetails, ["founderId", id]);
          const avatar = founder.avatar;

          return (
            <FounderBubble
              name={founder.founderName}
              avatar={avatar}
              status={status}
              key={id + "-" + this.props.targetId}
            />
          );
        }, this)}
      </div>
    );
  }
}

FounderStatusPanel.propTypes = {
  founderDetails: PropTypes.array,
  targetId: PropTypes.number,
  founderStatuses: PropTypes.array
};
