import React from "react";
import PropTypes from "prop-types";

export default class TargetsFilterOption extends React.Component {
  constructor(props) {
    super(props);

    // Memoize some values.
    this.level = this.loadLevel();

    this.handleClick = this.handleClick.bind(this);
  }

  handleClick() {
    if (this.level.unlocked && this.level.id !== this.props.rootState.chosenLevelId) {
      const trackIdsForLevel = this.props.getAvailableTrackIds(this.level.id);
      this.props.setRootState({
        chosenLevelId: this.level.id,
        activeTrackId: trackIdsForLevel[0]
      });
    }
  }

  loadLevel() {
    let that = this;

    return _.find(this.props.rootProps.levels, level => {
      return level.id === that.props.levelId;
    });
  }

  iconClasses() {
    if (!this.level.unlocked) {
      return "fa fa-lock";
    } else if (this.level.number > this.props.rootProps.currentLevel.number) {
      return "fa fa-eye";
    } else if (this.level.number < this.props.rootProps.currentLevel.number) {
      return "fa fa-check dark-primary";
    } else {
      return "fa fa-map-marker dark-secondary";
    }
  }

  styleClasses() {
    let classes = "dropdown-item filter-targets-dropdown__menu-item";
    if (!this.level.unlocked) {
      classes += " filter-targets-dropdown__menu-item--disabled";
    }
    return classes;
  }

  render() {
    return (
      <a
        className={this.styleClasses()}
        role="button"
        onClick={this.handleClick}
      >
        <span className="filter-targets-dropdown__menu-item-icon">
          <i className={this.iconClasses()} />
        </span>
        Level {this.level.number}: {this.level.name}
      </a>
    );
  }
}

TargetsFilterOption.propTypes = {
  levelId: PropTypes.number,
  getAvailableTrackIds: PropTypes.func.isRequired,
  rootProps: PropTypes.object.isRequired,
  rootState: PropTypes.object.isRequired,
  setRootState: PropTypes.func.isRequired
};
