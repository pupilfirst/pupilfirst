# @cjsx React.DOM

@StartupLinksSection = React.createClass
  # Display name used for debugging
  displayName: 'StartupLinksSection'

  # Invoked before the component is mounted and provides the initial state for the render method.
  getInitialState: ->
    # We'll change it to true once we fetch data
    didFetchData: false
    # The startup links JSON array used to display links in the view
    startupLinks: []

  # Invoked right after the component renders
  componentDidMount: ->
    # Let's fetch all startup links
    @_fetchStartupLinks({})

  # AJAX call to our StartupLinksController
  _fetchStartupLinks: (data) ->
    $.ajax
      url: Routes.startup_startup_links_path(@props.startup_id, format: 'json')
      dataType: 'json'
      data: data
    .done @_fetchDataDone
    .fail @_fetchDataFail

  # If the AJAX call is successful...
  _fetchDataDone: (data, textStatus, jqXHR) ->
    # We change the state of the component. This will cause the component and its children to render again.
    @setState
      didFetchData: true
      startupLinks: data

  # If errors in AJAX call...
  _fetchDataFail: (xhr, status, err) ->
    console.error @props.url, status, err.toString()

  # Handler for the submit event on AddStartupLink component
  _handleAddStartupLink: (name, url, description) ->
    # Let's attempt to create the startup link.
    @_createStartupLink
      name: name
      url: url
      description: description

  # How the component is going to be rendered to the user depending on its props and state...
  render: ->
    # The collection of StartupLink components we are going to display using the startup links stored in the component's state.
    startupLinksNode = @state.startupLinks.map (startupLink) ->
      # StartupLink component with a data property containing all the JSON attributes we are going to use to display it to the user.
      <StartupLink data={startupLink}/>

    # HTML displayed if no startup links found in its state.
    noDataNode =
      <em>No links found. Add some?</em>

    # HTML displayed when loading data.
    loadingDataNode =
      <em>Loading...</em>

    # Render result starts here. Let's keep the list of startup links in a bootstrap list-group.
    <ul className="list-group">
      {
        # If there are startup links, render the cards...
        if @state.startupLinks.length > 0
          { startupLinksNode }
        # Else, if has fetched data, but didn't find any cards, render warning message instead.
        else if @state.didFetchData
          { noDataNode }
        else
          { loadingDataNode }
      }
    </ul>
