class FounderDashboardSessionsTagSelect extends React.Component {
  componentDidMount() {
    $('.js-founder-dashboard-sessions-tag-select').select2({
      placeholder: "Filter by tags",
      maximumSelectionLength: 2
    });

    let that = this;

    $('.js-founder-dashboard-sessions-tag-select').on('change', function () {
      that.handleChange()
    });
  }

  componentWillUnmount() {
    $('.js-founder-dashboard-sessions-tag-select').select2('destroy')
  }

  tagOptions() {
    return this.props.tags.map(function (tag) {
      return <option key={ 'tag ' + tag}>{ tag }</option>;
    })
  }

  handleChange() {
    let selectedTags = $('.js-founder-dashboard-sessions-tag-select').val() || [];
    this.props.chooseTagsCB(selectedTags);
  }

  render() {
    return (
      <div className="founder-dashboard-sessions__tag-select-container">
        <select multiple="multiple"
          className="founder-dashboard-sessions__tag-select js-founder-dashboard-sessions-tag-select form-control">
          { this.tagOptions() }
        </select>
      </div>
    );
  }
}

FounderDashboardSessionsTagSelect.propTypes = {
  tags: React.PropTypes.array,
  chooseTagsCB: React.PropTypes.func
};
