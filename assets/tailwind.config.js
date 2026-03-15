// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")
const path = require("path")
const fs = require("fs")

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/devtodo_web.ex",
    "../lib/devtodo_web/**/*.*ex"
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        brand: "#6366f1",
      }
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    // Allows prefixing tailwind classes with LiveView classes to improve Tailwind integration
    // with LiveView features like form field errors and uploads.
    plugin(({addVariant}) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({addVariant}) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({addVariant}) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),

    // Embeds Heroicons (https://heroicons.com) into your app.css bundle
    // See your `mix.exs` file for the configuration options.
    plugin(function({matchComponents, theme}) {
      let iconsDir = path.join(__dirname, "../deps/heroicons/optimized")
      let values = {}
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"],
        ["-micro", "/16/solid"]
      ]
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).forEach(file => {
          let name = path.basename(file, ".svg") + suffix
          values[name] = {name, fullPath: path.join(iconsDir, dir, file)}
        })
      })
      matchComponents({
        "hero": ({name, fullPath}) => {
          let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
          let size = name.endsWith("-mini") ? "1.25rem" : name.endsWith("-micro") ? "1rem" : "1.5rem"
          return {
            [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
            "-webkit-mask": `var(--hero-${name})`,
            "mask": `var(--hero-${name})`,
            "mask-repeat": "no-repeat",
            "background-color": "currentColor",
            "vertical-align": "middle",
            "display": "inline-block",
            "width": size,
            "height": size
          }
        }
      }, {values})
    })
  ]
}
