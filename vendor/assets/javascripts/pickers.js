$(document).on('ready page:change', function() {
  $('.datepicker').datetimepicker({
      direction: 'bottom',
      pickTime: false
  });
});

$(document).on('ready page:change', function() {
  $('.datetimepicker').datetimepicker({
      direction: 'bottom',
pickSeconds: false
  });
});

$(document).on('ready page:change', function() {
  $('.timepicker').datetimepicker({
      direction: 'bottom',
      pickDate: false,
      pickSeconds: false
  });
});
