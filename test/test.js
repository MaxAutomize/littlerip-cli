'use strict';

const assert = require('node:assert/strict');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const commandPath = path.join(__dirname, '..', 'bin', 'littlerip');

function run(args = []) {
  return spawnSync(process.execPath, [commandPath, ...args], {
    encoding: 'utf8',
  });
}

const defaultRun = run();
assert.equal(defaultRun.status, 0);
assert.equal(defaultRun.stdout, 'littlerip\n');
assert.equal(defaultRun.stderr, '');

const versionRun = run(['--version']);
assert.equal(versionRun.status, 0);
assert.equal(versionRun.stdout, '1.0.0\n');

const helpRun = run(['--help']);
assert.equal(helpRun.status, 0);
assert.match(helpRun.stdout, /^Usage: littlerip$/m);
assert.match(helpRun.stdout, /Press Ctrl\+C to leave\./);

const invalidRun = run(['--not-a-real-option']);
assert.equal(invalidRun.status, 2);
assert.match(invalidRun.stderr, /unknown option/);

console.log('All tests passed.');
