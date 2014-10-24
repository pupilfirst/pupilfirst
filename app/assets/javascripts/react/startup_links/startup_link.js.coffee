# @cjsx React.DOM

@StartupLink = React.createClass
  displayName: 'StartupLink'
  getInitialState: ->
    deleted: false
  handleClick: (event) ->
    if confirm('Are you sure?')
      $.ajax
        url: Routes.startup_link_path(@props.data.id)
        type: 'DELETE'
      .done @_deleteStartupLinkDone
      .fail @_deleteStartupLinkFail
  _deleteStartupLinkDone: (data, textStatus, jqXHR) ->
    @setState
      deleted: true
  _deleteStartupLinkFail: (xhr, status, err) ->
    console.error @props.data.id, status, err.toString()

  render: ->
    descriptionNode =
      <span>&nbsp;&mdash; {@props.data.description}</span>

    <li className="list-group-item #{'startup-link-deleted' if this.state.deleted}">
      <a href="#{@props.data.url}">{@props.data.name}</a>
      {
        if @props.data.description
          { descriptionNode }
      }
      &nbsp;<button className="btn btn-xs btn-danger #{'startup-link-deleted' if this.state.deleted}" type="button" onClick={this.handleClick}>
        <span className="glyphicon glyphicon-remove" />
        &nbsp;Remove
      </button>
    </li>


