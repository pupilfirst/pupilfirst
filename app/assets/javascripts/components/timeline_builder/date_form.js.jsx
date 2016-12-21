class TimelineBuilderDateForm extends React.Component {
  constructor(props) {
    super(props);

    this.state = {date: this.today()};
    this.handleChange = this.handleChange.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  componentDidMount() {
    $('.js-timeline-builder__date-input').datetimepicker({
      startDate: this.state.date,
      scrollInput: false,
      scrollMonth: false,
      format: 'Y-m-d',
      timepicker: false,
      onSelectDate: this.handleChange
    })
  }

  today() {
    return moment().format('YYYY-MM-DD');
  }

  handleChange() {
    let m = moment($('.js-timeline-builder__date-input').val(), 'YYYY-MM-DD');
    let newDate = '';

    if (m.isValid()) {
      newDate = m.format('YYYY-MM-DD');
    } else {
      newDate = this.today();
    }

    this.setState({date: newDate});
  }

  handleSubmit(event) {
    event.preventDefault();

    console.log("Save " + this.state.date);
  }

  render() {
    return (
      <div>
        <input type="text" className="js-timeline-builder__date-input" placeholder="YYYY-MM-DD"
               onChange={ this.handleChange }/>
        <button type="submit" className="btn btn-secondary" onClick={ this.handleSubmit }>
          <i className="fa fa-check"/>
        </button>
      </div>
    )
  }
}
