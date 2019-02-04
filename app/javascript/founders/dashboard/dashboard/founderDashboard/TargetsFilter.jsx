import React from "react";
import PropTypes from "prop-types";
import TargetsFilterOption from "./TargetsFilterOption";

export default class TargetsFilter extends React.Component {
  levelOptions() {
    // Exclude level 0 from the dropdown
    let levels = this.props.rootProps.levels.filter(level => {return level.number > 0;});

    let sortedLevels = _.sortBy(levels, ["number"]);
    return _.map(sortedLevels, level => {
      return (
        <TargetsFilterOption
          key={level.id}
          levelId={level.id}
          getAvailableTrackIds={this.props.getAvailableTrackIds}
          rootProps={this.props.rootProps}
          rootState={this.props.rootState}
          setRootState={this.props.setRootState}
        />
      );
    });
  }

  render() {
    return (
      <div className="dropdown filter-targets-dropdown">
        <button
          aria-expanded="false"
          aria-haspopup="true"
          data-toggle="dropdown"
          type="button"
          className="d-flex btn btn-md px-3 filter-targets-dropdown__button align-items-center justify-content-between dropdown-toggle"
        >
          <span className="pr-3 filter-targets-dropdown__selection">
            Level {this.props.rootState.selectedLevel.number}: {this.props.rootState.selectedLevel.name}
          </span>

          <span className="filter-targets-dropdown__arrow" />
        </button>

        <div className="dropdown-menu filter-targets-dropdown__menu">
          {this.levelOptions()}
        </div>
      </div>
    );
  }
}

TargetsFilter.propTypes = {
  getAvailableTrackIds: PropTypes.func.isRequired,
  rootProps: PropTypes.object.isRequired,
  rootState: PropTypes.object.isRequired,
  setRootState: PropTypes.func.isRequired
};
