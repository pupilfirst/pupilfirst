import React from "react";
import PropTypes from "prop-types";
import FounderBubble from "./FounderBubble";

export default class FounderStatusPanel extends React.Component {
  render() {
    return (
      this.props.pendingFounderIds.length > 0 && (
        <div className="my-3 px-4">
          <h5 className="target-overlay__status-title font-semibold">
            Pending Team Members:
          </h5>

          <div className="founder-dashboard__avatars ml-2">
            {this.props.pendingFounderIds.map(id => {
              const founder = _.find(this.props.founderDetails, [
                "founderId",
                id
              ]);

              const avatar = founder.avatar;

              return (
                <FounderBubble
                  name={founder.founderName}
                  avatar={avatar}
                  key={id + "-" + this.props.targetId}
                />
              );
            }, this)}
          </div>
        </div>
      )
    );
  }
}

FounderStatusPanel.propTypes = {
  founderDetails: PropTypes.array,
  targetId: PropTypes.number,
  pendingFounderIds: PropTypes.array
};
