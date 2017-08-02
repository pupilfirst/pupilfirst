class FounderDashboardTarget extends React.Component {
  constructor(props) {
    super(props);
    this.handleClick = this.handleClick.bind(this);
  }

  handleClick() {
    this.props.selectTargetCB(this.props.target.id, this.props.target.target_type);
  }

  render() {
    return (
      <div className='founder-dashboard-target__container'>
        <FounderDashboardTargetHeader onClickCB={ this.handleClick } target={ this.props.target }
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
