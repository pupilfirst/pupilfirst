class EventsReviewDashboardEventTargetRubric extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
        <table>
          <thead>
          <tr>
            <th>
              Performance Criterion
            </th>
            <th>
              Good
            </th>
            <th>
              Great
            </th>
            <th>
              Wow
            </th>
          </tr>
          </thead>
          <tbody>
            { Object.keys(this.props.rubric).map(function (performanceCriteriaId) {
              return (<tr key={performanceCriteriaId}>
                <td> { this.props.rubric[performanceCriteriaId]['description'] } </td>
                <td> { this.props.rubric[performanceCriteriaId]['rubric_good'] } </td>
                <td> { this.props.rubric[performanceCriteriaId]['rubric_great'] } </td>
                <td> { this.props.rubric[performanceCriteriaId]['rubric_wow'] } </td>
              </tr>)}, this
            )}
          </tbody>
        </table>
    )
  }
}

EventsReviewDashboardEventTargetRubric.propTypes = {
  rootState: PropTypes.object,
  setRootState: PropTypes.func,
  rubric: PropTypes.object
};
