import React from "react";
import PropTypes from "prop-types";
import TargetCollection from "./TargetCollection";
import ActionBar from "./ActionBar";

export default class Sessions extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      filterTags: []
    };

    this.chooseTags = this.chooseTags.bind(this);
  }

  upcomingSessions() {
    return this.filteredSessions()
      .filter(function(target) {
        return moment(target.session_at).isAfter(moment());
      })
      .reverse();
  }

  pastSessions() {
    return this.filteredSessions().filter(function(target) {
      return moment(target.session_at).isBefore(moment());
    });
  }

  filteredSessions() {
    let that = this;

    return this.props.sessions.filter(function(target) {
      return that.targetHasTags(target, that.state.filterTags);
    });
  }

  targetHasTags(target, tags) {
    let targetTags = target.taggings.map(function(tagging) {
      return tagging.tag.name;
    });

    for (let tagIndex in tags) {
      if (!targetTags.includes(tags[tagIndex])) {
        return false;
      }
    }

    return true;
  }

  chooseTags(tags) {
    this.setState({ filterTags: tags });
  }

  render() {
    return (
      <div>
        <ActionBar
          filter="sessions"
          filterData={{ tags: this.props.sessionTags }}
          openTimelineBuilderCB={this.props.openTimelineBuilderCB}
          pickFilterCB={this.chooseTags}
          currentLevel={this.props.currentLevel}
        />

        {this.upcomingSessions().length > 0 && (
          <TargetCollection
            key="sessions-upcoming"
            name="Upcoming Sessions"
            displayDate={true}
            targets={this.upcomingSessions()}
            iconPaths={this.props.iconPaths}
            founderDetails={this.props.founderDetails}
            selectTargetCB={this.props.selectTargetCB}
          />
        )}

        <TargetCollection
          key="sessions-past"
          name="Past Sessions"
          displayDate={true}
          targets={this.pastSessions()}
          finalCollection={true}
          iconPaths={this.props.iconPaths}
          founderDetails={this.props.founderDetails}
          selectTargetCB={this.props.selectTargetCB}
        />
      </div>
    );
  }
}

Sessions.propTypes = {
  currentLevel: PropTypes.number,
  sessions: PropTypes.array,
  sessionTags: PropTypes.array,
  openTimelineBuilderCB: PropTypes.func,
  iconPaths: PropTypes.object,
  selectTargetCB: PropTypes.func
};
