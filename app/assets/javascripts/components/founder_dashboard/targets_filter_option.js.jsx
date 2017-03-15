class FounderDashboardTargetsFilterOption extends React.Component {
  constructor(props) {
    super(props);

    this.handleClick = this.handleClick.bind(this);
  }

  handleClick() {
    this.props.pickFilterCB(this.props.level);
  }

  render() {
    return (
      <a className="dropdown-item filter-targets-dropdown__menu-item" role="button" onClick={ this.handleClick }>
        <span className="filter-targets-dropdown__menu-item-icon">
          <i className="fa fa-line-chart"/>
        </span>

        Level { this.props.level }: { this.props.name }
      </a>
    );
  }
}

FounderDashboardTargetsFilterOption.propTypes = {
  name: React.PropTypes.string,
  level: React.PropTypes.number,
  pickFilterCB: React.PropTypes.func
};
