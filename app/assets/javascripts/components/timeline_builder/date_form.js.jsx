class TimelineBuilderDateForm extends React.Component {
  constructor(props) {
    super(props);

    let startDate = (props.selectedDate == null) ? this.today() : props.selectedDate;
    this.state = {date: startDate};

    this.handleChange = this.handleChange.bind(this);
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
    this.props.addAttachmentCB('date', {value: newDate});
  }

  render() {
    return (
      <div>
        <input type="text" className="js-timeline-builder__date-input" placeholder="YYYY-MM-DD"
               onChange={ this.handleChange }/>
      </div>
    )
  }
}

TimelineBuilderDateForm.props = {
  selectedDate: React.PropTypes.string,
  addAttachmentCB: React.PropTypes.func
};
