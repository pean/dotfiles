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
  { type: 'assign', label: 'assign', archive: true, slack: true },
  { type: 'author', label: 'author', archive: true, slack: false },
  { type: 'ci_activity', label: 'ci activity', archive: true, slack: false },
  { type: 'comment', label: 'comment', archive: true, slack: true },
  { type: 'manual', label: 'manual', archive: true, slack: true },
  { type: 'mention', label: 'mention', archive: true, slack: true },
  { type: 'push', label: 'push', archive: true, slack: false },
  { type: 'review_requested', label: 'review requested', archive: true, slack: true },
  { type: 'review', label: 'review', archive: true, slack: true },
  { type: 'security_alert', label: 'security alert', archive: true, slack: true },
  { type: 'state_change', label: 'state change', archive: true, slack: false },
  { type: 'subscribed', label: 'subscribed', archive: true, slack: false },
  { type: 'team_mention', label: 'team mention', archive: true, slack: true },
  { type: 'your_activity', label: 'your activity', archive: true, slack: true },
  { type: 'your_activity', label: 'your activity', archive: true, slack: true },
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
      forward: if notification.slack then variables.slack_email else null,
      labels: [
        'github',
        'github/' + notification.label,
      ],
    },
  }
  for notification in notifications
];

// Bot filters - using from: query to match display names in From header
local botFilters = [
  {
    filter: {
      and: [
        { from: 'notifications@github.com' },
        {
          or: [
            { query: 'from:(dependabot)' },
            { query: 'from:(linear)' },
            { query: 'from:("Dreams Bot")' },
          ],
        },
      ],
    },
    actions: {
      delete: true,
    },
  },
];

local rules = botFilters + notificationFilters;

local labels = lib.rulesLabels(rules);

local tests = [];

{
  version: 'v1alpha3',
  author: {
    name: 'Peter Andersson',
    email: 'peter.andersson@getdreams.com',
  },
  labels: labels,
  rules: rules,
  tests: tests,
}
