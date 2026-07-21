import type { Config } from '@docusaurus/types';

const config: Config = {
    title: 'Hallscloud Handbook',
    tagline: 'Living documentation for hallscloud.org',
    favicon: 'img/favicon.ico',

    url: 'https://handbook.hallscloud.org',
    baseUrl: '/',

    organizationName: 'markupstart',
    projectName: 'nixos_configs',

    onBrokenLinks: 'throw',

    i18n: {
        defaultLocale: 'en',
        locales: ['en'],
    },

    presets: [
        [
            'classic',
            {
                docs: {
                    routeBasePath: '/docs',
                    sidebarPath: './sidebars.ts',
                    editUrl: 'https://github.com/markupstart/nixos_configs',
                },
                blog: false,
                theme: {
                    customCss: './src/css/custom.css',
                },
            },
        ],
    ],

    markdown: {
        hooks: {
            onBrokenMarkdownLinks: 'warn',
        },
    },

    themeConfig: {
        navbar: {
            title: 'Hallscloud Handbook',
            items: [
                {
                    type: 'docSidebar',
                    sidebarId: 'docsSidebar',
                    position: 'left',
                    label: 'Handbook',
                },
                {
                    href: 'https://github.com/markupstart/nixos_configs',
                    label: 'GitHub',
                    position: 'right',
                },
            ],
        },
        footer: {
            style: 'dark',
            links: [
                {
                    title: 'Handbook',
                    items: [
                        {
                            label: 'Getting Started',
                            to: '/docs/intro',
                        },
                        {
                            label: 'Migration Plan',
                            to: '/docs/migration-plan',
                        },
                    ],
                },
            ],
            copyright: `Copyright © ${new Date().getFullYear()} Hallscloud`,
        },
        prism: {
            theme: {
                plain: {
                    color: '#111827',
                    backgroundColor: '#f8fafc',
                },
                styles: [],
            },
            darkTheme: {
                plain: {
                    color: '#e5e7eb',
                    backgroundColor: '#111827',
                },
                styles: [],
            },
        },
    },
};

export default config;