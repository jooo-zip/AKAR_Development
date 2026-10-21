import { test } from 'node:test';
import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { moduleRoot } from '../src/config.js';

test('existing Godot project and hotspot files have no staged or unstaged changes relative to HEAD', () => {
  const protectedPaths = ['project.godot', 'scenes', 'scripts', 'data', 'assets', 'resources', 'tests'];
  const changed = execFileSync('git', ['--no-optional-locks', 'diff', '--name-only', 'HEAD', '--', ...protectedPaths], {
    cwd: resolve(moduleRoot, '..'), encoding: 'utf8',
  });
  assert.equal(changed.trim(), '', `Unexpected changes to Godot files:\n${changed}`);
});

test('module is excluded from Godot import and generated/sensitive files are ignored by Git', () => {
  assert.equal(readFileSync(resolve(moduleRoot, '.gdignore'), 'utf8').trim(), '');
  const names = ['node_modules/example/index.js', 'data/analytics.sqlite', '.env', '.env.local',
    'custom.sqlite', 'custom.sqlite-wal', 'custom.sqlite-shm', 'custom.db', 'tmp/test.txt'];
  const ignored = execFileSync('git', ['--no-optional-locks', 'check-ignore', '--stdin'], {
    cwd: moduleRoot, input: names.join('\n') + '\n', encoding: 'utf8',
  }).trim().split(/\r?\n/);
  assert.deepEqual(ignored, names);
});
