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
  target: PropTypes.object,
  displayDate: PropTypes.bool,
  iconPaths: PropTypes.object,
  selectTargetCB: PropTypes.func
};
