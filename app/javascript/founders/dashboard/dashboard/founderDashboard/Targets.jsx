import React from "react";
import PropTypes from "prop-types";
import TargetCollection from "./TargetCollection";

export default class Targets extends React.Component {
  targetGroups() {
    let levelToShow = (this.props.rootState.selectedTab === 'levelZero') ?
      this.props.rootProps.levels.find(level => {return level.number == 0;}) :
      this.props.rootState.selectedLevel;

    let filteredTargetGroups = this.props.rootProps.targetGroups.filter(targetGroup => {
      return targetGroup.level.id === levelToShow.id;
    });

    return _.sortBy(filteredTargetGroups, ["sort_index"]);
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
          hasSingleFounder={this.props.hasSingleFounder}
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
  selectTargetCB: PropTypes.func.isRequired,
  hasSingleFounder: PropTypes.bool
};
