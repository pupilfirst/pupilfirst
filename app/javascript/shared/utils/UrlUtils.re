let isInvalid = url => {
  let trimmedUrl = url |> String.trim;

  if (trimmedUrl |> String.length > 0) {
    let regex = [%re
      {|/^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/|}
    ];
    !Js.Re.test_(regex, url);
  } else {
    true;
  };
};