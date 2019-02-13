import React from "react";
import PropTypes from "prop-types";

export default class ToggleBarTab extends React.Component {
  constructor(props) {
    super(props);

    this.handleClick = this.handleClick.bind(this);
  }

  handleClick() {
    let selectedTab = this.props.level.number == 0 ? 'levelZero' : 'selectedLevel' ;
    this.props.setRootState({ selectedTab: selectedTab });
  }

  isSelectedTab() {
    let isActiveLevelZero = this.props.rootState.selectedTab === 'levelZero' && this.props.level.number === 0;
    let isActiveSelectedLevel =  this.props.rootState.selectedTab === 'selectedLevel' && this.props.rootState.selectedLevel === this.props.level;
    return isActiveLevelZero || isActiveSelectedLevel;
  }

  labelClasses() {
    let classes = "btn founder-dashboard-togglebar__toggle-btn btn-md m-a-0";
    return this.isSelectedTab() ? classes + " active" : classes;
  }

  render() {
    return (
      <div className={this.labelClasses()} onClick={this.handleClick}>
        {this.props.level.name.toUpperCase()}
      </div>
    );
  }
}

ToggleBarTab.propTypes = {
  level: PropTypes.object.isRequired,
  rootProps: PropTypes.object.isRequired,
  rootState: PropTypes.object.isRequired,
  setRootState: PropTypes.func.isRequired
};
