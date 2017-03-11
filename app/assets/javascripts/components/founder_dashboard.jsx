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
        <FounderDashboardTargets/>
        }

        { this.state.activeTab === 'chores' &&
        <FounderDashboardChores/>
        }

        { this.state.activeTab === 'sessions' &&
        <FounderDashboardSessions/>
        }
      </div>
    );
  }
}
