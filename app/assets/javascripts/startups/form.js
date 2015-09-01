$(function () {
  counter = function (ele, help_ele, max_chars, is_words) {
    var value = $(ele).val();

    if (value.length == 0) {
      $(help_ele).html(0 + "/" + max_chars + " " + (is_words ? "words" : "characters"));
      return;
    }

    var regex = /\s+/gi;
    var wordCount = value.trim().replace(regex, ' ').split(' ').length;
    var charCount = value.trim().length;


    $(help_ele).html((is_words ? wordCount : charCount) + "/" + max_chars + " characters");
  };

  update_about = function () {
    var help_ele = $(".startup_about p.help-block");
    var ele = $(".startup_about #startup_about");

    // The value of max_chars should match the one in Startup::MAX_ABOUT_CHARACTERS
    counter(ele, help_ele, 150)
  };

  $("#startup_about").click(update_about)
    .change(update_about)
    .keydown(update_about)
    .keypress(update_about)
    .keyup(update_about)
    .blur(update_about)
    .focus(update_about);
});
