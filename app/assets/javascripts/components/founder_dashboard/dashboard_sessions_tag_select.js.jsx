class FounderDashboardSessionsTagSelect extends React.Component {
  componentDidMount() {
    $('.js-founder-dashboard-sessions-tag-select').select2(
      { placeholder: "Filter by tags",
        maximumSelectionLength: 2
    })
  }

  componentWillUnmount() {
    $('.js-founder-dashboard-sessions-tag-select').select2('destroy')
  }

  render() {
    return (
      <div className="founder-dashboard-sessions__tag-select-container">
        <div className="input-group">
          <select className="founder-dashboard-sessions__tag-select js-founder-dashboard-sessions-tag-select form-control" multiple="multiple">
            <option>Idea Discovery</option>
            <option>Prototyping</option>
            <option>Customer Validation</option>
          </select>
          <span className="input-group-btn">
            <button className="btn btn-md btn-ghost-secondary btn-session-tag-select" type="button">
              <i className="fa fa-search"/>
            </button>
          </span>
        </div>
      </div>
    );
  }
}
