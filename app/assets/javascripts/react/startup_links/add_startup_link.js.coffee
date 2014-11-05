# @cjsx React.DOM

@AddStartupLink = React.createClass
  displayName: 'AddStartupLink'

  # Submit handler
  _handleOnSubmit: (e) ->
    e.preventDefault()

    # Get values
    name = @refs.name.getDOMNode().value.trim()
    url = @refs.url.getDOMNode().value.trim()
    description = @refs.description.getDOMNode().value.trim()

    # Triggers its custom onFormSubmit event passing values
    @props.onFormSubmit(name, url, description)

  render: ->
    <li class="list-group-item">
    <form accept-charset="UTF-8" action="/" class="simple_form form-inline" id="new_startup_link" method="post" novalidate="novalidate">
    <div style="display:none">
    <input name="utf8" type="hidden" value="✓">
    <input name="authenticity_token" type="hidden" value="MLvNFsGiVdNqNLyZftIbuDkgwoSgt/yWiunTz5mPi6Y="></div><div class="form-group string optional startup_link_name"><label class="string optional sr-only" for="startup_link_name">Name</label><input class="string optional form-control" id="startup_link_name" name="startup_link[name]" placeholder="Name" type="text"></div>&nbsp;<div class="form-group url optional startup_link_url"><label class="url optional sr-only" for="startup_link_url">Url</label><input class="string url optional form-control" id="startup_link_url" name="startup_link[url]" placeholder="URL" type="url"></div>&nbsp;<div class="form-group string optional startup_link_description"><label class="string optional sr-only" for="startup_link_description">Description</label><input class="string optional form-control" id="startup_link_description" name="startup_link[description]" placeholder="Description (optional)" type="text"></div>&nbsp;<button class="btn btn-primary" type="submit"><span class="glyphicon glyphicon-plus"></span> Add a link</button></form></li>
    <div className="add-startup-link-wrapper">
      <div className="form-wrapper">
        <form onSubmit={@_handleOnSubmit}>
          <input ref="name" placeholder="Name"/>
          <input ref="url" placeholder="URL"/>
          <input ref="description" placeholder="Description (optional)"/>
        </form>
      </div>
    </div>
