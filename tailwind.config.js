const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  theme: {
    colors: {
      ...defaultTheme.colors,
      primary: {
        100: '#F0EAFB',
        200: '#D3BFF3',
        300: '#B08EE6',
        400: '#976AE2',
        500: '#6025C0',
        600: '#4D1E9A',
        700: '#380D80',
        800: '#35156B',
        900: '#1F0D40',
      },
      secondary: {
        100: '#FEE6EF',
        200: '#FCB5D0',
        300: '#FF80B0',
        400: '#F95392',
        500: '#F61067',
        600: '#AC0645',
        700: '#A61149',
        800: '#7B0531',
        900: '#4A031E',
      },
    },
  }
}