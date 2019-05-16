[@bs.config {jsx: 3}];

let str = React.string;

let reasonCode = {|
<span class="prism-token prism-keyword">def</span>
```reason
/* A sample fizzbuzz implementation. */
let fizzbuzz = (num) =>
  switch (num mod 3, num mod 5) {
  | (0, 0) => "FizzBuzz"
  | (0, _) => "Fizz"
  | (_, 0) => "Buzz"
  | _ => string_of_int(num)
  };

for (i in 1 to 100) {
  Js.log(fizzbuzz(i))
};
```|};

let rubyCode = {|```ruby
# A sample fizzbuzz implementation.
def fizzbuzz(num)
  a = String.new
  a << "Fizz" if num%3 == 0
  a << "Buzz" if num%5 == 0
  a << num.to_s if a.empty?
  a
end

(1.100).each do |i|
  puts fizzbuzz(i)
end
```|};

let jsCode = {|```javascript
// A sample fizzbuzz implementation.
const fizzbuzz = (num) => {
  if (i % 3 === 0){
    return('fizz');
  }
  else if (i % 5 === 0){
    return('buzz');
  }
  else if (i % (5 * 3) === 0){
    return('fizzbuzz');
  } else {
    return(i);
  }
};

for(var i = 1; i <= num; i++) {
  console.log(fizzbuzz(i));
}
```|};

[@react.component]
let make = () => {
  let (show, setShow) = React.useState(() => true);

  <div>
    <button onClick={_event => setShow(s => !s)}>
      {"Toggle code" |> str}
    </button>
    {
      if (show) {
        <div>
          <p className="text-xs font-semibold"> {"ReasonML" |> str} </p>
          <div
            className="mt-2"
            dangerouslySetInnerHTML={"__html": reasonCode |> Markdown.parse}
          />
          <p className="mt-4 text-xs font-semibold"> {"Ruby" |> str} </p>
          <div
            className="mt-2"
            dangerouslySetInnerHTML={"__html": rubyCode |> Markdown.parse}
          />
          <p className="mt-4 text-xs font-semibold"> {"Javascript" |> str} </p>
          <div
            className="mt-2"
            dangerouslySetInnerHTML={"__html": jsCode |> Markdown.parse}
          />
        </div>;
      } else {
        React.null;
      }
    }
  </div>;
};