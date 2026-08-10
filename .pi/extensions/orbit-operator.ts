import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const COMMANDS = {
  "orbit-launch": {
    skill: "orbit-launch",
    description: "Prepare an ORBIT Mission/Orbit and briefing context",
    safety:
      "Establish or prepare context only. Do not plan Crew Orders, execute Crew, create GO, or Dispatch.",
  },
  "orbit-plan": {
    skill: "orbit-plan",
    description: "Run ORBIT Mission Control planning and create bounded Crew Orders",
    safety:
      "Plan only. Create bounded orders through the existing skill; do not execute Crew or create authority.",
  },
  "orbit-analyze": {
    skill: "orbit-analyze",
    description: "Execute existing ORBIT Crew Orders through the configured runtime",
    safety:
      "Use existing Crew Orders only. Stop on any Firstmate eligibility or provenance HOLD; do not fall back to sequential, create GO, broaden authority, or Dispatch.",
  },
  "orbit-status": {
    skill: "orbit-status",
    description: "Show read-only ORBIT Mission Control status",
    safety:
      "Read-only. Do not modify Mission data, Crew Orders, Gate Control, or Mission State.",
  },
  "orbit-gate": {
    skill: "orbit-gate",
    description: "Record an explicit human ORBIT Gate Control decision",
    safety:
      "Record authority only when the human explicitly supplies status, scope, authority, and target. Never infer GO.",
  },
  "orbit-close": {
    skill: "orbit-close",
    description: "Validate and prepare an ORBIT packet for human review",
    safety:
      "Prepare review only. Never promote candidate Mission State, create GO, or Dispatch.",
  },
} as const;

type OrbitCommand = keyof typeof COMMANDS;

function operatorPrompt(command: OrbitCommand, args: string): string {
  const config = COMMANDS[command];
  const suppliedArgs = args.trim() || "(none supplied; use an existing active ORBIT context only if it is unambiguous)";

  return [
    `Run the Pi ORBIT operator command /${command}.`,
    `Read and follow the existing project skill at .agents/skills/${config.skill}/SKILL.md before acting.`,
    "Use the canonical ORBIT CLI under ./bin/orbit and the existing runtime interfaces; do not duplicate ORBIT business logic.",
    `Explicit command arguments: ${suppliedArgs}`,
    "If the arguments do not identify one unambiguous Mission/Orbit and no authoritative active context exists, ask for the missing context instead of guessing.",
    config.safety,
    "Preserve ORBIT ownership of Mission State, Crew Orders, Crew Returns, reconciliation, Gate Control, and Mission Packets. Preserve Firstmate ownership of worker execution and supervision.",
  ].join("\n");
}

export default function (pi: ExtensionAPI) {
  for (const command of Object.keys(COMMANDS) as OrbitCommand[]) {
    const config = COMMANDS[command];
    pi.registerCommand(command, {
      description: config.description,
      handler: async (args, ctx) => {
        await ctx.waitForIdle();
        await pi.sendUserMessage(operatorPrompt(command, args));
      },
    });
  }
}
