class EventsReviewDashboardEventGrading extends React.Component {
  constructor(props) {
    super(props);

    this.toggleRubric = this.toggleRubric.bind(this);
  }

  toggleRubric() {
    const reviewDataClone = _.cloneDeep(this.props.rootState.reviewData);
    const eventData = reviewDataClone[this.props.eventId];

    if (_.isBoolean(eventData.rubricVisible)) {
      eventData.rubricVisible = !eventData.rubricVisible;
    } else {
      eventData.rubricVisible = true;
    }

    this.props.setRootState({reviewData: reviewDataClone});

  }

  radioInputId(name, pcId) {
    return name + '-' + this.props.eventId + '-' + pcId;
  }

  radioInputName(name, pcId) {
    return 'event-' + this.props.eventId + '-' + pcId + name;
  }

  render(){
    return(<div>
        <strong>Grade for each PC:</strong>
        <br/>
        {/*<label htmlFor={ this.radioInputId('wow') }>*/}
          {/*<input type='radio' id={this.radioInputId('wow') } value='wow' name={ this.radioInputName('grade') }*/}
                 {/*onChange={ this.gradeChange }/>&nbsp;Wow&nbsp;*/}
        {/*</label>*/}
        {/*<label htmlFor={ this.radioInputId('great') }>*/}
          {/*<input type='radio' id={ this.radioInputId('great') } value='great' name={ this.radioInputName('grade') }*/}
                 {/*onChange={ this.gradeChange }/>&nbsp;*/}
          {/*Great&nbsp;*/}
        {/*</label>*/}
        {/*<label htmlFor={ this.radioInputId('good') }>*/}
          {/*<input type='radio' id={ this.radioInputId('good') } value='good' name={ this.radioInputName('grade') }*/}
                 {/*onChange={ this.gradeChange }/>&nbsp;*/}
          {/*Good&nbsp;*/}
        {/*</label>*/}

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
          { Object.keys(this.props.rubric).map(function (pcId) {
            return (<tr key={pcId}>
              <td> { this.props.rubric[pcId]['description'] } </td>
              <td> <input type='radio' id={this.radioInputId('wow', pcId) } value='wow' name={ this.radioInputName('grade', pcId) }
                          onChange={ this.gradeChange }/> </td>
              <td> <input type='radio' id={this.radioInputId('wow', pcId) } value='wow' name={ this.radioInputName('grade', pcId) }
                          onChange={ this.gradeChange }/> </td>
              <td> <input type='radio' id={this.radioInputId('wow', pcId) } value='wow' name={ this.radioInputName('grade', pcId) }
                          onChange={ this.gradeChange }/> </td>
            </tr>)}, this
          )}
          </tbody>
        </table>
      <a className='button cursor-pointer margin-bottom-10' onClick={this.toggleRubric}>Show/Hide Rubric</a>
      </div>
    )
  }
}

EventsReviewDashboardEventGrading.propTypes = {
  rootState: PropTypes.object,
  setRootState: PropTypes.func,
  eventId: PropTypes.string,
  targetId: PropTypes.string,
  rubric: PropTypes.object
};
