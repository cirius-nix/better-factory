// services/factory site configuration (spec-site-render).
// The factory owns this file with the copy mode managed.
// The file reads ./site.json for title, url, baseUrl, staticDirectories,
// and featureOrder, and renders the docs tree at the site root.
// The one sidebar comparator below keeps the priority order of the spec:
// the feature position in site.featureOrder, then index or README first,
// then the phase rank requirements, specifications, decisions, tasks, then
// the semantic version order below versions, then change-initial first
// below changes, then the case-insensitive label compare.
const site = require('./site.json');

// The ordered feature list is repository data. It travels only through
// site.featureOrder; this file holds no hand list of feature names.
const featureOrder = site.featureOrder || [];

function orderOfFeature(name) {
  const position = featureOrder.indexOf(name);
  return position === -1 ? Number.MAX_SAFE_INTEGER : position;
}

function baseOf(source) {
  if (!source) return '';
  const parts = source.split('/');
  return parts[parts.length - 1];
}

function isFeatureName(name) {
  return typeof name === 'string' && name.indexOf('feat-') === 0;
}

// An index or README document precedes each other item in its parent folder.
function isIndexDocument(name) {
  const base = baseOf(name).toLowerCase();
  return base === 'index' || base === 'readme';
}

// The artifact phase rank: requirements, specifications, decisions, tasks.
const phaseRankOf = {
  requirements: 0,
  specifications: 1,
  decisions: 2,
  tasks: 3,
};

function phaseRank(name) {
  const base = baseOf(name).toLowerCase();
  if (Object.prototype.hasOwnProperty.call(phaseRankOf, base)) {
    return phaseRankOf[base];
  }
  return Number.MAX_SAFE_INTEGER;
}

function parseSemver(name) {
  const base = baseOf(name);
  const match = /^(\d+)\.(\d+)\.(\d+)$/.exec(base);
  if (!match) return null;
  return {
    major: Number(match[1]),
    minor: Number(match[2]),
    patch: Number(match[3]),
  };
}

// The fallback compares display labels without letter case via toLowerCase.
// Two equal labels compare the original labels, then the source identities.
function compareLabels(aLabel, bLabel, aId, bId) {
  const lowerA = String(aLabel).toLowerCase();
  const lowerB = String(bLabel).toLowerCase();
  if (lowerA < lowerB) return -1;
  if (lowerA > lowerB) return 1;
  if (aLabel < bLabel) return -1;
  if (aLabel > bLabel) return 1;
  if (aId < bId) return -1;
  if (aId > bId) return 1;
  return 0;
}

// Each special rule applies only to its item type and parent folder.
function compareEntries(a, b, parent) {
  // Feature folders use their zero-based position in featureOrder.
  // A listed folder precedes an unlisted folder.
  if (isFeatureName(a.name) && isFeatureName(b.name)) {
    const rank = orderOfFeature(a.name) - orderOfFeature(b.name);
    if (rank !== 0) return rank;
  }
  // An index or README document comes first in its parent folder.
  const indexA = a.kind === 'doc' && isIndexDocument(a.name);
  const indexB = b.kind === 'doc' && isIndexDocument(b.name);
  if (indexA !== indexB) return indexA ? -1 : 1;
  // An artifact phase folder uses the phase rank.
  if (a.kind === 'dir' && b.kind === 'dir') {
    const rank = phaseRank(a.name) - phaseRank(b.name);
    if (rank !== 0) return rank;
  }
  // Under a versions folder, semantic-version folders descend.
  // A valid version precedes an invalid version folder.
  if (parent === 'versions') {
    const versionA = parseSemver(a.name);
    const versionB = parseSemver(b.name);
    if (versionA && versionB) {
      if (versionA.major !== versionB.major) return versionB.major - versionA.major;
      if (versionA.minor !== versionB.minor) return versionB.minor - versionA.minor;
      if (versionA.patch !== versionB.patch) return versionB.patch - versionA.patch;
    } else if (versionA) {
      return -1;
    } else if (versionB) {
      return 1;
    }
  }
  // Under a changes folder, change-initial precedes the other folders.
  if (parent === 'changes') {
    const initialA = baseOf(a.name) === 'change-initial';
    const initialB = baseOf(b.name) === 'change-initial';
    if (initialA !== initialB) return initialA ? -1 : 1;
  }
  return compareLabels(a.label || a.name, b.label || b.name, a.name, b.name);
}

function withGeneratedIndex(items) {
  return items.map((item) => {
    if (item.type !== 'category') return item;
    const next = { ...item, items: withGeneratedIndex(item.items || []) };
    if (!next.link) {
      next.link = { type: 'generated-index', title: next.label, slug: '/' + next.label };
    }
    return next;
  });
}

function sortLevel(items, parent) {
  const sorted = items.slice().sort((a, b) =>
    compareEntries(
      { name: a.label || '', kind: a.type === 'doc' ? 'doc' : 'dir', label: a.label || '' },
      { name: b.label || '', kind: b.type === 'doc' ? 'doc' : 'dir', label: b.label || '' },
      parent,
    ),
  );
  return sorted.map((item) => {
    if (item.type === 'category' && item.items) {
      return { ...item, items: sortLevel(item.items, item.label) };
    }
    return item;
  });
}

async function sidebarItemsGenerator({ defaultSidebarItemsGenerator, ...args }) {
  const items = await defaultSidebarItemsGenerator(args);
  return sortLevel(withGeneratedIndex(items), null);
}

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: site.title,
  url: site.url,
  baseUrl: site.baseUrl,
  staticDirectories: site.staticDirectories,
  trailingSlash: true,
  onBrokenLinks: 'warn',
  onBrokenMarkdownLinks: 'warn',
  markdown: {
    format: 'detect',
  },
  presets: [
    [
      'classic',
      {
        blog: false,
        docs: {
          path: '../../docs',
          routeBasePath: '/',
          sidebarPath: './sidebars.js',
          numberPrefixParser: false,
          exclude: [
            '**/_*.{js,jsx,ts,tsx,md,mdx}',
            '**/_*/**',
            '**/*.test.{js,jsx,ts,tsx}',
            '**/__tests__/**',
            '**/templates/**',
          ],
          sidebarItemsGenerator,
        },
        theme: {
          customCss: './src/css/custom.css',
        },
      },
    ],
  ],
  themeConfig: {
    navbar: {
      title: site.title,
    },
  },
};

module.exports = config;
module.exports.compareEntries = compareEntries;
