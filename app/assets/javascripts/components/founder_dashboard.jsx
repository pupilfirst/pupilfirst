class FounderDashboard extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      activeTab: 'targets',
      timelineBuilderVisible: false,
      timelineBuilderParams: {
        targetId: null,
        selectedTimelineEventTypeId: null
      }
    };

    this.chooseTab = this.chooseTab.bind(this);
    this.closeTimelineBuilder = this.closeTimelineBuilder.bind(this);
    this.openTimelineBuilder = this.openTimelineBuilder.bind(this);
  }

  chooseTab(tab) {
    this.setState({activeTab: tab});
  }

  closeTimelineBuilder() {
    this.setState({timelineBuilderVisible: false});
  }

  openTimelineBuilder(targetId, selectedTimelineEventTypeId) {
    let builderParams = {
      targetId: targetId || null,
      selectedTimelineEventTypeId: selectedTimelineEventTypeId || null
    };

    this.setState({timelineBuilderVisible: true, timelineBuilderParams: builderParams});
  }

  render() {
    return (
      <div className="founder-dashboard-container p-b-2">
        <FounderDashboardToggleBar selected={ this.state.activeTab } chooseTabCB={ this.chooseTab }
          openTimelineBuilderCB={ this.openTimelineBuilder }/>

        { this.state.activeTab === 'targets' &&
        <FounderDashboardTargets currentLevel={ this.props.currentLevel } levels={ this.props.levels }
          openTimelineBuilderCB={ this.openTimelineBuilder }/>
        }

        { this.state.activeTab === 'chores' &&
        <FounderDashboardChores currentLevel={ this.props.currentLevel } chores={ this.props.chores }
          openTimelineBuilderCB={ this.openTimelineBuilder }/>
        }

        { this.state.activeTab === 'sessions' &&
        <FounderDashboardSessions sessions={ this.props.sessions } openTimelineBuilderCB={ this.openTimelineBuilder }/>
        }

        { this.state.timelineBuilderVisible &&
        <TimelineBuilder timelineEventTypes={ this.props.timelineEventTypes }
          allowFacebookShare={ this.props.allowFacebookShare } authenticityToken={ this.props.authenticityToken }
          closeTimelineBuilderCB={ this.closeTimelineBuilder } targetId={ this.state.timelineBuilderParams.targetId }
          selectedTimelineEventTypeId={ this.state.timelineBuilderParams.selectedTimelineEventTypeId }/>
        }
      </div>
    );
  }
}

FounderDashboard.propTypes = {
  currentLevel: React.PropTypes.number,
  levels: React.PropTypes.object,
  chores: React.PropTypes.array,
  sessions: React.PropTypes.array,
  timelineEventTypes: React.PropTypes.object,
  allowFacebookShare: React.PropTypes.bool,
  authenticityToken: React.PropTypes.string
};
