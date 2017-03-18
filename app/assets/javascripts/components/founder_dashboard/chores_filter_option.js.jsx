class FounderDashboardChoresFilterOption extends React.Component {
  constructor(props) {
    super(props);

    this.handleClick = this.handleClick.bind(this);
  }

  dropdownIcon(status) {
    return {
      all: 'fa-filter',
      pending: 'fa-hourglass-start',
      submitted: 'fa-check-square-o',
      completed: 'fa-thumbs-o-up',
      not_accepted: 'fa-thumbs-o-down',
      needs_improvement: 'fa-line-chart'
    }[status];
  }

  handleClick() {
    this.props.pickFilterCB(this.props.name);
  }

  render() {
    return (
      <a className="dropdown-item filter-targets-dropdown__menu-item" role="button" onClick={this.handleClick}>
          <span className="filter-targets-dropdown__menu-item-icon">
            <i className={'fa ' + this.dropdownIcon(this.props.name)}/>
          </span>
        {this.props.dropdownLabel(this.props.name)}
      </a>
    );
  }
}
