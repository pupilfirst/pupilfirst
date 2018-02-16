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
    if (this.level.id !== this.props.rootState.chosenLevelId) {
      const trackIdsForLevel = this.props.getAvailableTrackIds(this.level.id);
      this.props.setRootState({ chosenLevelId: this.level.id, activeTrackId: trackIdsForLevel[0] });
    }
  }

  locked() {
    return this.level.number > this.props.rootProps.currentLevel.number;
  }

  loadLevel() {
    let that = this;

    return _.find(this.props.rootProps.levels, level => {
      return level.id === that.props.levelId;
    });
  }

  iconClasses() {
    if (this.locked()) {
      return "fa fa-lock";
    } else {
      return "fa fa-unlock";
    }
  }

  styleClasses() {
    let classes = "dropdown-item filter-targets-dropdown__menu-item";
    if (this.locked()) {
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
