module.exports = {
  title: "Pupilfirst Developers",
  tagline: "Focus on your students.",
  url: "https://developers.pupilfirst.com",
  baseUrl: "/",
  favicon: "https://school.sv.co/favicon.png",
  organizationName: "pupilfirst", // Usually your GitHub org/user name.
  projectName: "pupilfirst", // Usually your repo name.
  themeConfig: {
    navbar: {
      title: "Pupilfirst Developers",
      logo: {
        alt: "Pupilfirst Logo",
        src: "https://school.sv.co/favicon.png"
      },
      links: [
        {
          to: "docs/",
          activeBasePath: "docs",
          label: "Docs",
          position: "left"
        },
        {
          href: "https://pupilfirst.com",
          label: "Home",
          position: "right"
        },
        {
          href: "https://github.com/pupilfirst/pupilfirst",
          label: "GitHub",
          position: "right"
        }
      ]
    },
    footer: {
      style: "dark",
      links: [
        {
          title: "Docs",
          items: [
            {
              label: "Style Guide",
              to: "docs/"
            },
            {
              label: "Second Doc",
              to: "docs/doc2/"
            }
          ]
        },
        {
          title: "Community",
          items: [
            {
              label: "Discord",
              href: "https://discord.gg/Sh67Tca"
            },
            {
              label: "Twitter",
              href: "https://twitter.com/pupilfirstlms"
            }
          ]
        },
        {
          title: "More",
          items: [
            {
              label: "Blog",
              to: "blog"
            },
            {
              label: "GitHub",
              href: "https://github.com/facebook/docusaurus"
            }
          ]
        }
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Pupilfirst Ltd. Built with Docusaurus.`
    },
    prism: {
      additionalLanguages: ["ruby", "bash"]
    }
  },
  presets: [
    [
      "@docusaurus/preset-classic",
      {
        docs: {
          // It is recommended to set document id as docs home page (`docs/` path).
          homePageId: "intro",
          sidebarPath: require.resolve("./sidebars.js"),
          // Please change this to your repo.
          editUrl:
            "https://github.com/pupilfirst/pupilfirst/edit/improve-developer-docs/docs/developers/"
        },
        theme: {
          customCss: require.resolve("./src/css/custom.css")
        }
      }
    ]
  ]
};
