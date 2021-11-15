// Auto-imported filters by 'gmailctl download'.
//
// WARNING: This functionality is experimental. Before making any
// changes, check that no diff is detected with the remote filters by
// using the 'diff' command.

// Uncomment if you want to use the standard library.
local lib = import 'gmailctl.libsonnet';
local variables = import 'variables.libsonnet';

// GitHub notifications as cc
local notifications = [
  { type: 'assign', label: 'assign', archive: false },
  { type: 'author', label: 'author', archive: true },
  { type: 'ci_activity', label: 'ci activity', archive: true },
  { type: 'comment', label: 'comment', archive: true },
  { type: 'manual', label: 'manual', archive: false },
  { type: 'mention', label: 'mention', archive: false },
  { type: 'push', label: 'push', archive: true },
  { type: 'review_requested', label: 'review requested', archive: false },
  { type: 'security_alert', label: 'security alert', archive: false },
  { type: 'state_change', label: 'state change', archive: true },
  { type: 'subscribed', label: 'subscribed', archive: true },
  { type: 'team_mention', label: 'team mention', archive: false },
  { type: 'your_activity', label: 'your activity', archive: false },
  { type: 'your_activity', label: 'your activity', archive: false },
];

local notificationFilters = [
  {
    filter: {
      and: [
        { from: 'notifications@github.com' },
        { cc: notification.type + '@noreply.github.com' },
      ],
    },
    actions: {
      archive: notification.archive,
      forward: if notification.archive == false then variables.slack_email else null,
      labels: [
        'github/' + notification.label,
      ],
    },
  }
  for notification in notifications
];

local rules = notificationFilters + [
  {
    filter: {
      and: [
        { from: 'dependabot[bot]' },
      ],
    },
    actions: {
      archive: true,
      labels: [
        'github/dependabot',
      ],
    },
  },
];

local labels = lib.rulesLabels(rules) + [
  { name: 'jonas-and-youtube' },
];

local tests = [
  {
    name: 'dependabot goes to github/dependabot',
    messages: [
      { from: 'dependabot[bot]' },
    ],
    actions: {
      archive: true,
      labels: [
        'github/dependabot',
      ],
    },
  },
];

{
  version: 'v1alpha3',
  author: {
    name: 'Peter Andersson',
    email: 'peter.andersson@hemnet.se',
  },
  labels: labels,
  rules: rules,
  tests: tests,
}
