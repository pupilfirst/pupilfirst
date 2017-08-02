class FounderDashboardTarget extends React.Component {
  render() {
    return (
      <div className='founder-dashboard-target__container'>
        <FounderDashboardTargetHeader onClickCB={ this.props.selectTargetCB } target={ this.props.target }
                                      displayDate={ this.props.displayDate } iconPaths={ this.props.iconPaths }/>
      </div>
    );
  }
}

FounderDashboardTarget.propTypes = {
  target: React.PropTypes.object,
  displayDate: React.PropTypes.bool,
  iconPaths: React.PropTypes.object,
  selectTargetCB: React.PropTypes.func
};
