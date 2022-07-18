import { defineConfig } from 'vite'
import rubyPlugin from 'vite-plugin-ruby'
import babel from 'vite-plugin-babel'

export default defineConfig({
  plugins: [
    rubyPlugin(),
    babel(),
  ],
})
