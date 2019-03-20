showFileNameInAvatarField = ->
  $('.custom-file-input').on 'change', ->
    debugger
    fileName = $(this).val().split('\\').pop()
    $(this).next('.custom-file-label').addClass('selected').html fileName

$(document).on 'turbolinks:load', ->
    showFileNameInAvatarField()

