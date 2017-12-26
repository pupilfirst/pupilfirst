import React from "react";

// Reference for this component: https://gist.github.com/cbilgili/89cab4196a6018daef26
export default class TrixEditor extends React.Component {
  constructor(props) {
    super(props);
    this.onChange = this.onChange.bind(this);
  }

  componentDidMount() {
    this.trix = ReactDOM.findDOMNode(this);
    $(document).on("trix-change", this.onChange);
  }

  componentWillUnmount() {
    $(document).off("trix-change", this.onChange);
  }

  onChange(event) {
    if (event.target === this.trix) {
      this.props.onChange(event.target.value);
    }
  }

  render() {
    return <trix-editor />;
  }
}
