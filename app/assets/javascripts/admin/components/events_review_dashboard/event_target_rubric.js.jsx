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
                <td> <div><span className='review-dashboard-event-target-rubric__skill-title'>{ this.props.rubric[skillId]['name'] }</span> <br/>
                  <span>{ this.props.rubric[skillId]['description'] } </span></div> </td>
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
