import React from "react";
import PropTypes from "prop-types";
import TargetCollection from "./TargetCollection";

export default class Targets extends React.Component {
  targetGroups() {
    let activeTrackId = null;

    if (this.props.rootState.activeTrackId !== "default") {
      activeTrackId = this.props.rootState.activeTrackId;
    }

    const chosenLevelId = this.props.rootState.chosenLevelId;

    // Return target groups that are in the selected track.
    return _.filter(this.props.rootProps.targetGroups, targetGroup => {
      if (targetGroup.level.id !== chosenLevelId) {
        return false;
      }

      // If target group is in a track, check if track ID matches. If not in track, the activeTrackID must be null.
      if (_.isObject(targetGroup.track)) {
        return targetGroup.track.id === activeTrackId;
      } else {
        return activeTrackId === null;
      }
    });
  }

  targetCollections() {
    let collectionLength = this.targetGroups().length;

    return this.targetGroups().map((targetGroup, targetGroupIndex) => {
      let finalCollection = collectionLength === targetGroupIndex + 1;

      return (
        <TargetCollection
          key={targetGroup.id}
          targetGroupId={targetGroup.id}
          finalCollection={finalCollection}
          rootProps={this.props.rootProps}
          rootState={this.props.rootState}
          setRootState={this.props.setRootState}
          selectTargetCB={this.props.selectTargetCB}
        />
      );
    }, this);
  }

  render() {
    return <div>{this.targetCollections()}</div>;
  }
}

Targets.propTypes = {
  rootProps: PropTypes.object.isRequired,
  rootState: PropTypes.object.isRequired,
  setRootState: PropTypes.func.isRequired,
  selectTargetCB: PropTypes.func.isRequired
};
