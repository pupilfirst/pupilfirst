module.exports = {
  title: "Pupilfirst LMS",
  tagline: "Focus on your students.",
  url: "https://docs.pupilfirst.com",
  baseUrl: "/",
  favicon: "https://www.pupilfirst.school/favicon.png",
  organizationName: "pupilfirst", // Usually your GitHub org/user name.
  projectName: "pupilfirst", // Usually your repo name.
  themeConfig: {
    navbar: {
      title: "Pupilfirst LMS",
      logo: {
        alt: "Pupilfirst Logo",
        src: "https://www.pupilfirst.school/favicon.png",
      },
      items: [
        {
          to: "users/",
          activeBasePath: "users",
          label: "Users",
          position: "left",
        },
        {
          to: "developers/",
          activeBasePath: "developers",
          label: "Developers",
          position: "left",
        },
        {
          href: "https://lms.pupilfirst.org",
          label: "Home",
          position: "right",
        },
        {
          href: "https://github.com/pupilfirst/pupilfirst",
          label: "GitHub",
          position: "right",
        },
      ],
    },
    footer: {
      style: "dark",
      links: [
        {
          title: "Developer Docs",
          items: [
            {
              label: "Introduction",
              to: "developers/",
            },
            {
              label: "Development Setup",
              to: "developers/development_setup/",
            },
          ],
        },
        {
          title: "User Docs",
          items: [
            {
              label: "Introduction",
              to: "users/",
            },
          ],
        },
        {
          title: "Community",
          items: [
            {
              label: "Discord",
              href: "https://discord.gg/Sh67Tca",
            },
            {
              label: "Twitter",
              href: "https://twitter.com/pupilfirstlms",
            },
          ],
        },
        {
          title: "More",
          items: [
            {
              label: "Blog",
              to: "https://blog.pupilfirst.org/",
            },
            {
              label: "GitHub",
              href: "https://github.com/pupilfirst/pupilfirst",
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Pupilfirst Pvt. Ltd. Built with Docusaurus.`,
    },
    prism: {
      additionalLanguages: ["ruby", "bash"],
    },
  },
  presets: [
    [
      "@docusaurus/preset-classic",
      {
        docs: {
          path: "users",
          routeBasePath: "users",
          sidebarPath: require.resolve("./sidebarsUsers.js"),
        },
        theme: {
          customCss: require.resolve("./src/css/custom.css"),
        },
      },
    ],
  ],
  plugins: [
    [
      "@docusaurus/plugin-content-docs",
      {
        id: "developers",
        path: "developers",
        routeBasePath: "developers",
        sidebarPath: require.resolve("./sidebarsDevelopers.js"),
        editUrl: "https://github.com/pupilfirst/pupilfirst/edit/master/docs/",
        // ... other options
      },
    ],
  ],
};
