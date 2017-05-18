class FounderDashboardTargetsFilterOption extends React.Component {
  constructor(props) {
    super(props);

    this.handleClick = this.handleClick.bind(this);
  }

  handleClick() {
    if (this.props.level <= this.props.currentLevel) {
      this.props.pickFilterCB(this.props.level);
    }
  }

  locked() {
    return this.props.level > this.props.currentLevel;
  }

  iconClasses() {
    if (this.locked()) {
      return 'fa fa-lock';
    } else {
      return 'fa fa-unlock';
    }
  }

  styleClasses() {
    let classes = 'dropdown-item filter-targets-dropdown__menu-item'
    if (this.locked()) {
      classes += ' filter-targets-dropdown__menu-item--disabled'
    }
    return classes;
  }

  render() {
    return (
      <a className={ this.styleClasses() } role="button" onClick={ this.handleClick }>
        <span className="filter-targets-dropdown__menu-item-icon">
          <i className={ this.iconClasses() }/>
        </span>

        Level { this.props.level }: { this.props.name }
      </a>
    );
  }
}

FounderDashboardTargetsFilterOption.propTypes = {
  name: React.PropTypes.string,
  level: React.PropTypes.number,
  pickFilterCB: React.PropTypes.func,
  currentLevel: React.PropTypes.number
};
