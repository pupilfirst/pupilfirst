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
              Skill
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
            { Object.keys(this.props.rubric).map(function (skillId) {
              return (<tr key={skillId}>
                <td> { this.props.rubric[skillId]['description'] } </td>
                <td> { this.props.rubric[skillId]['rubric_good'] } </td>
                <td> { this.props.rubric[skillId]['rubric_great'] } </td>
                <td> { this.props.rubric[skillId]['rubric_wow'] } </td>
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
