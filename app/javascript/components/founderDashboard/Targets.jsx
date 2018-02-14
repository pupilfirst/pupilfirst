import React from "react";
import PropTypes from "prop-types";
import ActionBar from "./ActionBar";
import LevelUpNotification from "./LevelUpNotification";
import TargetCollection from "./TargetCollection";

export default class Targets extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      chosenLevel: props.currentLevel
    };

    this.pickFilter = this.pickFilter.bind(this);
  }

  targetGroups() {
    return this.props.levels[this.state.chosenLevel].target_groups;
  }

  targetCollections() {
    let collectionLength = this.targetGroups().length;

    return this.targetGroups().map(function (targetGroup, targetGroupIndex) {
      let finalCollection = collectionLength === targetGroupIndex + 1;

      return <TargetCollection key={targetGroup.id} name={targetGroup.name}
        description={targetGroup.description} targets={targetGroup.targets} milestone={targetGroup.milestone}
        finalCollection={finalCollection} iconPaths={this.props.iconPaths} founderDetails={this.props.founderDetails}
        selectTargetCB={this.props.selectTargetCB} currentLevel={this.props.currentLevel}/>
    }, this);
  }

  filterData() {
    return {
      levels: this.props.programLevels,
      chosenLevel: this.state.chosenLevel
    };
  }

  pickFilter(level) {
    this.setState({chosenLevel: level});
  }

  render() {
    return (
      <div>
        {this.props.levelUpEligibility !== 'not_eligible' &&
        <LevelUpNotification authenticityToken={this.props.authenticityToken}
          levelUpEligibility={this.props.levelUpEligibility} currentLevel={this.props.currentLevel}
          maxLevelNumber={this.props.maxLevelNumber}/>
        }

        {this.props.currentLevel !== 0 &&
        <ActionBar filter='targets' filterData={this.filterData()} pickFilterCB={this.pickFilter}
          openTimelineBuilderCB={this.props.openTimelineBuilderCB} currentLevel={this.props.currentLevel}/>
        }

        {this.targetCollections()}
      </div>
    );
  }
}

Targets.propTypes = {
  currentLevel: PropTypes.number,
  levels: PropTypes.object,
  openTimelineBuilderCB: PropTypes.func,
  levelUpEligibility: PropTypes.string,
  authenticityToken: PropTypes.string,
  iconPaths: PropTypes.object,
  founderDetails: PropTypes.array,
  maxLevelNumber: PropTypes.number,
  programLevels: PropTypes.object,
  selectTargetCB: PropTypes.func
};
