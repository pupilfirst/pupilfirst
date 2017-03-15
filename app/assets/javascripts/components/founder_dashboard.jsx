class FounderDashboard extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      activeTab: 'targets'
    };

    this.chooseTab = this.chooseTab.bind(this);
  }

  chooseTab(tab) {
    this.setState({activeTab: tab});
  }

  render() {
    return (
      <div className="founder-dashboard-container p-b-2">
        <FounderDashboardToggleBar selected={ this.state.activeTab } chooseTabCB={ this.chooseTab }/>

        { this.state.activeTab === 'targets' &&
        <FounderDashboardTargets levels={ this.props.levels }/>
        }

        { this.state.activeTab === 'chores' &&
        <FounderDashboardChores chores={ this.props.chores }/>
        }

        { this.state.activeTab === 'sessions' &&
        <FounderDashboardSessions sessions={ this.props.sessions }/>
        }
      </div>
    );
  }
}

FounderDashboard.propTypes = {
  levels: React.PropTypes.object,
  chores: React.PropTypes.array,
  sessions: React.PropTypes.array,
};
