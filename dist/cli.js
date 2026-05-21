"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
const fs = __importStar(require("fs"));
const path = __importStar(require("path"));
const os = __importStar(require("os"));
const readline = __importStar(require("readline"));
const SKILLS_DIR = path.join(__dirname, '..', 'skills');
const AGENTS = [
    { id: 'claude', label: 'Claude Code  (project-level, committed to git)', dest: '.claude/skills', userLevel: false },
    { id: 'claude-user', label: 'Claude Code  (user-level, all your projects)', dest: '.claude/skills', userLevel: true },
    { id: 'cursor', label: 'Cursor', dest: '.cursor/skills', userLevel: false },
    { id: 'copilot', label: 'GitHub Copilot', dest: '.github/copilot/skills', userLevel: false },
    { id: 'gemini', label: 'Gemini CLI', dest: '.gemini/skills', userLevel: true },
    { id: 'codex', label: 'Codex / agentskills.io', dest: '.agents/skills', userLevel: false },
];
// Always overwrite on reinstall
const MANAGED = new Set([
    'fe-test/SKILL.md',
    'fe-test/references/bad-patterns.md',
    'fe-test/references/quality-gates.md',
    'fe-test/references/adapters/svelte.md',
    'fe-test-learn/SKILL.md',
    'fe-testing-setup/SKILL.md',
    'README.md',
]);
// Never overwrite if already exists (user-owned after first install)
const USER_OWNED = new Set([
    'fe-test/knowledge/global-learnings.md',
]);
function walk(dir, base = dir) {
    const results = [];
    for (const entry of fs.readdirSync(dir)) {
        const full = path.join(dir, entry);
        if (fs.statSync(full).isDirectory()) {
            results.push(...walk(full, base));
        }
        else {
            results.push(path.relative(base, full));
        }
    }
    return results;
}
function resolveBase(agent) {
    return agent.userLevel
        ? path.join(os.homedir(), agent.dest)
        : path.join(process.cwd(), agent.dest);
}
function install(agent) {
    const base = resolveBase(agent);
    const isReinstall = fs.existsSync(path.join(base, 'fe-test', 'SKILL.md'));
    const files = walk(SKILLS_DIR);
    let installed = 0;
    let preserved = 0;
    for (const rel of files) {
        const src = path.join(SKILLS_DIR, rel);
        const dest = path.join(base, rel);
        const exists = fs.existsSync(dest);
        if (USER_OWNED.has(rel) && exists) {
            preserved++;
            continue;
        }
        if (isReinstall && !MANAGED.has(rel) && !USER_OWNED.has(rel) && exists) {
            preserved++;
            continue;
        }
        fs.mkdirSync(path.dirname(dest), { recursive: true });
        fs.copyFileSync(src, dest);
        installed++;
    }
    const tag = isReinstall ? 'updated' : 'installed';
    const note = preserved > 0 ? `, ${preserved} user file${preserved > 1 ? 's' : ''} preserved` : '';
    console.log(`  ✓ ${agent.label}: ${installed} files ${tag}${note}`);
}
function prompt(question) {
    return new Promise(resolve => {
        const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
        rl.question(question, answer => { rl.close(); resolve(answer.trim()); });
    });
}
async function selectAgentsInteractive() {
    console.log('  Which agents do you want to install for?\n');
    AGENTS.forEach((a, i) => console.log(`    ${i + 1}. ${a.label}`));
    console.log(`    ${AGENTS.length + 1}. All of the above\n`);
    const input = await prompt('  Enter numbers separated by commas: ');
    if (input === String(AGENTS.length + 1) || input.toLowerCase() === 'all') {
        return AGENTS;
    }
    const indices = input.split(',').map(s => parseInt(s.trim(), 10) - 1);
    return indices.filter(i => i >= 0 && i < AGENTS.length).map(i => AGENTS[i]);
}
async function main() {
    const args = process.argv.slice(2);
    console.log('\n  fe-test — frontend testing skill installer\n');
    let selected;
    if (args.includes('--all')) {
        selected = AGENTS;
    }
    else {
        const flagged = AGENTS.filter(a => args.includes(`--${a.id}`));
        selected = flagged.length > 0 ? flagged : await selectAgentsInteractive();
    }
    if (selected.length === 0) {
        console.log('\n  No agents selected. Exiting.\n');
        process.exit(0);
    }
    console.log('');
    for (const agent of selected) {
        install(agent);
    }
    console.log('\n  Done. Run /fe-test in your agent to get started.\n');
}
main().catch(err => {
    console.error('\n  Error:', err.message, '\n');
    process.exit(1);
});
