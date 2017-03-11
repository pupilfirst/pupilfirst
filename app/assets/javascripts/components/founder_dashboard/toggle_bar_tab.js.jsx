class FounderDashboardToggleBarTab extends React.Component {
  constructor(props) {
    super(props);

    this.handleClick = this.handleClick.bind(this);
  }

  tabName() {
    return this.props.tabType.toUpperCase();
  }

  handleClick() {
    if (this.props.chosen) {
      return
    }

    this.props.chooseTabCB(this.props.tabType);
  }

  labelClasses() {
    let classes = 'btn founder-dashboard-togglebar__toggle-btn btn-md m-a-0';
    return this.props.chosen ? classes + ' active' : classes;
  }

  render() {
    return (
      <label className={ this.labelClasses() } onClick={ this.handleClick }>
        { this.props.pendingCount > 0 &&
        <span className="badge badge-pill badge-primary founder-dashboard-togglebar__toggle-btn-notify">
          { this.props.pendingCount }
        </span>
        }

        { this.tabName() }
      </label>
    )
  }
}

FounderDashboardToggleBarTab.propTypes = {
  tabType: React.PropTypes.string,
  pendingCount: React.PropTypes.number,
  chooseTabCB: React.PropTypes.func,
  chosen: React.PropTypes.bool
};
