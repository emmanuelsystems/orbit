---
name: orbit-init
description: Initialize a new recurring Mission in ORBIT, establish its Mission Charter and private state home, and keep user-specific meeting data outside the distro repo. Use when the user asks to create, configure, or onboard a recurring meeting into ORBIT.
user-invocable: true
---

# orbit-init

Initialize a Mission without inventing organizational rules. Read `README.md`, `AGENTS.md`, and `templates/mission-charter.md`; resolve a Mission slug and name; run `./bin/orbit init <slug> "<name>"`; fill only explicitly provided facts; leave unknown authority and routing unresolved; report the private Mission-home path and next command; do not commit private Mission state into the distro repo.
