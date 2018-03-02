import React from "react";
import PropTypes from "prop-types";

export default class DatePicker extends React.Component {
  constructor(props) {
    super(props);

    let startDate =
      props.selectedDate == null ? this.today() : props.selectedDate;
    this.state = { date: startDate };

    this.handleChange = this.handleChange.bind(this);
  }

  componentDidMount() {
    $(".js-timeline-builder__date-input").datetimepicker({
      startDate: this.state.date,
      scrollInput: false,
      scrollMonth: false,
      inline: true,
      format: "Y-m-d",
      timepicker: false,
      onSelectDate: this.handleChange
    });

    $("#date-form__date-modal").modal();
  }

  componentWillUnmount() {
    $("#date-form__date-modal").modal("hide");
    $(".js-timeline-builder__date-input").datetimepicker("destroy");
  }

  today() {
    return moment().format("YYYY-MM-DD");
  }

  handleChange() {
    let m = moment($(".js-timeline-builder__date-input").val(), "YYYY-MM-DD");
    let newDate = "";

    if (m.isValid()) {
      newDate = m.format("YYYY-MM-DD");
    } else {
      newDate = this.today();
    }
    this.props.handleDate(newDate);
  }
  modalClasses() {
    let classes = "timeline-builder modal";

    if (!this.props.testMode) {
      classes += " fade";
    }

    return classes;
  }

  render() {
    return (
      <input
        id="timeline-builder__date-input"
        type="text"
        className="js-timeline-builder__date-input timeline-builder__date-input form-control"
        placeholder={this.today()}
        onClick={this.handleChange}
      />
    );
  }
}

DatePicker.propTypes = {
  selectedDate: PropTypes.string,
  handleDate: PropTypes.func
};
