class FounderDashboardFounderStatusPanel extends React.Component {
  constructor(props) {
    super(props);
    this.state = {founderStatuses: this.setInitialStatuses()};
    this.updateStatus = this.updateStatus.bind(this);
  }

  componentWillReceiveProps(newProps) {
    if (newProps.fetchStatus && !this.props.fetchStatus) {
      // fetch the founder statuses
      console.log('Fetching founder statuses');

      let that = this;
      $.ajax({
        url: '/founder/dashboard/founder_target_statuses/' + that.props.targetId,
        success: that.updateStatus
      });
    }
  }

  updateStatus(response) {
    this.setState({founderStatuses: response});
  }

  setInitialStatuses() {
    let initialStatuses = [];

    this.props.founderDetails.map(function(founderDetail) {
      let entry = {};
      entry[founderDetail.founderId] = 'loading';
      initialStatuses.push(entry);
    });

    return initialStatuses;
  }

  render() {
    return (
      <div className="founder-dashboard__avatars">
        { this.state.founderStatuses.map(function(founderStatus){
          let id = Object.keys(founderStatus)[0];
          let status = founderStatus[id];
          let founder = $.grep(this.props.founderDetails, function(e){ return e.founderId == id; })[0];
          let avatar = founder.avatar;

          return <FounderDashboardFounderBubble name={founder.founderName} avatar={avatar} status={status} key={id + '-' + this.props.targetId}/>
        }, this)}
      </div>
    )
  }
}

FounderDashboardFounderStatusPanel.PropTypes = {
  founderDetails: React.PropTypes.array,
  targetId: React.PropTypes.number,
  fetchStatus: React.PropTypes.bool
};
