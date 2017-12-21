import React from "react";
import PropTypes from "prop-types";
import FounderInput from "./FounderInput";

export default class FounderDetails extends React.Component {
  constructor(props) {
    super(props);

    let useCollegeText = false;

    if (
      props.founder.fields.college_id === null &&
      props.founder.fields.college_text != null
    ) {
      useCollegeText = true;
    }

    this.state = {
      useCollegeText: useCollegeText,
      focusOnCollegeText: false,
      emailHintHidden: false,
      addHiddenIgnoreInput: false
    };

    this.handleCollegeChange = this.handleCollegeChange.bind(this);
    this.handleDelete = this.handleDelete.bind(this);
    this.handleReplacementChoiceCB = this.handleReplacementChoiceCB.bind(this);
  }

  canDelete() {
    return !this.persisted() && this.props.allowDelete;
  }

  componentDidMount() {
    if (!this.state.useCollegeText) {
      let collegeSelect = $("#" + this.selectId());

      collegeSelect.select2({
        minimumInputLength: 3,
        placeholder: "Please pick your college",
        ajax: {
          url: this.props.collegesUrl,
          dataType: "json",
          delay: 500,
          data: function(params) {
            return {
              q: params.term
            };
          },
          processResults: function(data) {
            return { results: data };
          },
          cache: true
        }
      });

      // TODO: Remove this positioning hack when select2 bug is fixed. https://trello.com/c/H5l3oL7o
      let select2Instance = collegeSelect.data("select2");

      select2Instance.on("results:message", function() {
        this.dropdown._resizeDropdown();
        this.dropdown._positionDropdown();
      });

      collegeSelect.on("change", this.handleCollegeChange);
    }
  }

  componentWillUnmount() {
    this.destroySelect2();
  }

  destroySelect2() {
    $(this.selectId()).select2("destroy");
  }

  selectId() {
    return "founders-form__college-select-" + this.props.index;
  }

  handleCollegeChange(event) {
    if (event.target.value === "other") {
      this.destroySelect2();
      this.setState({ useCollegeText: true, focusOnCollegeText: true });
    }
  }

  errorForField(field) {
    if (this.props.founder.errors[field]) {
      return this.props.founder.errors[field][0];
    } else {
      return null;
    }
  }

  founderValue(field) {
    return this.props.founder.fields[field];
  }

  hasCollege() {
    return this.founderValue("college_id") !== null;
  }

  persisted() {
    return (
      typeof this.founderValue("id") !== "undefined" &&
      this.founderValue("id") !== null &&
      this.founderValue("id") !== ""
    );
  }

  deleteCheckboxId() {
    return "founders-form__founder-delete-checkbox-" + this.props.index;
  }

  handleDelete() {
    this.props.deleteCB(this.props.index);
  }

  deleteText() {
    if (this.props.founder.fields.invited) {
      return "Delete invitation";
    } else {
      return "Remove this founder";
    }
  }

  replacementHint() {
    if (typeof this.props.founder.fields.replacement_hint !== "undefined") {
      return this.props.founder.fields.replacement_hint;
    }
  }

  handleReplacementChoiceCB(choice, emailInputId) {
    if (choice === "yes") {
      $("#" + emailInputId).val(this.props.founder.fields.replacement_hint);
      this.setState({ emailHintHidden: true });
    } else {
      this.setState({ emailHintHidden: true, addHiddenIgnoreInput: true });
    }
  }

  showEmailHint() {
    return this.replacementHint() !== null && !this.state.emailHintHidden;
  }

  render() {
    return (
      <div className="founders-form__founder-content-box content-box">
        {this.canDelete() && (
          <div
            className="founders-form__founder-delete-button"
            onClick={this.handleDelete}
          >
            <i className="fa fa-times-circle" />
          </div>
        )}

        {this.props.founder.fields.invited && (
          <div className="alert alert-warning" role="alert">
            <i className="fa fa-exclamation-triangle" />&nbsp;&nbsp;
            <strong>Invitation pending:</strong> This founder hasn't yet
            accepted the invitation to join your startup. Please let them know
            that an email has been sent to their mailbox with a link to accept
            your invitation.
          </div>
        )}

        {this.persisted() && (
          <input
            className="hidden"
            type="hidden"
            value={this.founderValue("id")}
            name={
              "admissions_founders[founders_attributes][" +
              this.props.index +
              "][id]"
            }
          />
        )}

        {this.state.addHiddenIgnoreInput && (
          <input
            className="hidden"
            type="hidden"
            value="true"
            name={
              "admissions_founders[founders_attributes][" +
              this.props.index +
              "][ignore_email_hint]"
            }
          />
        )}

        <FounderInput
          label="Name"
          index={this.props.index}
          key={"name-" + this.props.generatedKey}
          maxLength={250}
          name="name"
          type="string"
          value={this.founderValue("name")}
          error={this.errorForField("name")}
        />

        <FounderInput
          label="Email address"
          index={this.props.index}
          key={"email-" + this.props.generatedKey}
          maxLength={250}
          name="email"
          type="email"
          error={this.errorForField("email")}
          value={this.founderValue("email")}
          disabled={this.persisted()}
          replacementHint={this.replacementHint()}
          handleReplacementChoiceCB={this.handleReplacementChoiceCB}
          showEmailHint={this.showEmailHint()}
        />

        {this.persisted() && (
          <input
            className="hidden"
            type="hidden"
            value={this.founderValue("id")}
            name={
              "admissions_founders[founders_attributes][" +
              this.props.index +
              "][id]"
            }
          />
        )}

        <FounderInput
          label="Mobile phone number"
          index={this.props.index}
          key={"phone-" + this.props.generatedKey}
          maxLength={17}
          name="phone"
          type="tel"
          pattern="\+?[0-9]{8,16}"
          value={this.founderValue("phone")}
          error={this.errorForField("phone")}
        />

        {!this.state.useCollegeText && (
          <div className="form-group select required">
            <label
              className="control-label select required"
              htmlFor={this.selectId()}
            >
              <abbr title="required">*</abbr> College
            </label>

            <select
              defaultValue={this.founderValue("college_id")}
              className="form-control select required"
              required="required"
              aria-required="true"
              id={this.selectId()}
              name={
                "admissions_founders[founders_attributes][" +
                this.props.index +
                "][college_id]"
              }
            >
              <option value="" />
              {this.hasCollege() && (
                <option value={this.founderValue("college_id")}>
                  {this.props.collegeName}
                </option>
              )}
              {!this.hasCollege() && (
                <option value="other">My college isn't listed</option>
              )}
            </select>
          </div>
        )}

        {this.state.useCollegeText && (
          <FounderInput
            label="Name of your college"
            index={this.props.index}
            type="string"
            key={"college-text-" + this.props.generatedKey}
            maxLength={250}
            autofocus={this.state.focusOnCollegeText}
            error={this.errorForField("college_text")}
            name="college_text"
            value={this.founderValue("college_text")}
          />
        )}

        {this.persisted() && (
          <div className="form-group boolean optional">
            <div className="checkbox">
              <label
                className="boolean optional"
                htmlFor={this.deleteCheckboxId()}
              >
                <input
                  className="boolean optional"
                  type="checkbox"
                  defaultChecked={false}
                  name={
                    "admissions_founders[founders_attributes][" +
                    this.props.index +
                    "][delete]"
                  }
                  id={this.deleteCheckboxId()}
                />
                &nbsp;&nbsp;{this.deleteText()}
              </label>
            </div>
          </div>
        )}
      </div>
    );
  }
}

FounderDetails.propTypes = {
  founder: PropTypes.object,
  collegesUrl: PropTypes.string,
  index: PropTypes.number,
  collegeName: PropTypes.string,
  deleteCB: PropTypes.func,
  allowDelete: PropTypes.bool,
  generatedKey: PropTypes.string
};
