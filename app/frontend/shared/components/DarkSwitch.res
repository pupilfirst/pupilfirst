let theme = %raw(`
function(){
let _theme =  localStorage.getItem('color-theme') === 'dark' ||
        (!('color-theme' in localStorage) && window.matchMedia('(prefers-color-scheme: dark)').matches) ?
            'dark' : 'light';
  if(_theme === 'dark') document.documentElement.classList.add('dark');
  return _theme;
}
`)

let toggleDarkMode = %raw(`
  function(theme) {
  if (theme === 'light') {
            document.documentElement.classList.add('dark');
            localStorage.setItem('color-theme', 'dark');
        } else {
            document.documentElement.classList.remove('dark');
            localStorage.setItem('color-theme', 'light');
        }
  }
`)

let darkSwitchClasses = condition => condition ? "fas fa-moon" : "fas fa-sun "

let darkSwitch = () => {
  let (_theme, setTheme) = React.useState(() => theme())
  let toggleTheme = _ => {
    toggleDarkMode(theme())
    setTheme(_prev => theme())
  }

  React.useEffect1(() => {None}, [theme])

  <div key="Dark-switch" className="mx-2 cursor-pointer" onClick=toggleTheme>
    <FaIcon classes={darkSwitchClasses(_theme == "light")} />
  </div>
}
