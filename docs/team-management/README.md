# docs/team-management/ — Team Management & Workflows

**PURPOSE**: Detailed workflows, procedures, and role definitions for all team managers (Atlas, Kim.G, Lee.C, Park.O).

## Contents

| File | Purpose | Audience |
|------|---------|----------|
| **TEAM_WORKFLOWS.md** | Complete role definitions, daily/weekly workflows, SLA definitions | All managers, team leads |

## Team Manager Roles

### 👤 **Steve PM** (Human Project Manager)
- **Responsibility**: Strategic decisions, roadmap priorities, combats system final choice
- **Timezone**: America/Los_Angeles (PST/PDT)
- **Communication**: Bilingual (Korean/English)

### 🤖 **Atlas (AI PM)** - OpenClaw
- **Model**: Claude Haiku 4-5 ($35/month)
- **Responsibilities**: Team coordination, documentation, Git workflows, approval routing
- **Fallback**: Claude Haiku 4-5 → Gemini 2.5 Pro → Gemini Flash
- **SLA**: <2 minutes for critical decisions

### 🎮 **Kim.G** (Game Manager)
- **Model**: Gemini 2.5 Pro ($35/month)
- **Responsibilities**: Game design, combat systems, mechanic implementation, developer coordination
- **Team**: Game development team
- **Current Focus**: Phase 4 dev preparation, combat implementation guides

### 📝 **Lee.C** (Content Manager)
- **Model**: Gemini 2.5 Pro ($20/month) [Upgraded 2026-02-28]
- **Responsibilities**: Blog automation, content strategy, SNS management, narrative design
- **Team**: Content/narrative team
- **Current Focus**: Blog posting automation via GeekBrox skill

### ⚙️ **Park.O** (Ops Manager)
- **Model**: Gemini 2.5 Pro ($25/month)
- **Responsibilities**: Infrastructure, resource allocation, budget monitoring, team operations
- **Team**: Operations team
- **Current Focus**: Team onboarding, documentation management

## Daily Workflows

### Morning Standup (9:00 AM PST)
```
Atlas reports to Steve:
- Phase 3 progress update
- Any blockers or decisions needed
- 3-week roadmap status
```

### Instant Task Management
```
Steve → [Decision/Request] → Atlas → [Route to Kim.G/Lee.C/Park.O] → Execute
```

### Escalation Path
```
Manager Issue → Atlas → Steve (if unresolved in 5s)
Rule 3: All fallback chains fail → Steve manual intervention + alert
```

## Task Prioritization (SLA)

| Priority | Response | Duration | Owner |
|----------|----------|----------|-------|
| 🔴 **CRITICAL** | Immediate | <5 min | All |
| 🟠 **HIGH** | <30 min | <2 hours | Primary |
| 🟡 **MEDIUM** | <2 hours | <1 day | Primary |
| 🟢 **LOW** | <1 day | <1 week | Primary |

## Model Configuration & Fallback Chain

**All Managers Use Unified Strategy:**
```
Primary Model ──[wait 5s if fail]──> Fallback1 ──[wait 5s if fail]──> Fallback2
  │                                     │                             │
  └─ Kim.G/Lee.C/Park.O:              └─ Claude Haiku 4-5          └─ Gemini Flash
     Gemini 2.5 Pro
  └─ Atlas:
     Claude Haiku 4-5
```

**If All Fail (Rule 3):** Alert Steve immediately with context

## Daily Manager Responsibilities

### Atlas (AI PM)
- [ ] Morning: Read MEMORY.md + memory/YYYY-MM-DD.md
- [ ] Team coordination: Route decisions to appropriate managers
- [ ] Git workflow: Commit → Report → Await approval → Push
- [ ] Notion sync: Update key documents after approval
- [ ] Documentation: Maintain TEAM_WORKFLOWS.md, README files
- [ ] Escalation: Alert Steve for critical decisions

### Kim.G (Game Manager)
- [ ] Monitor Phase 3 planning progress (target: 3/21 completion)
- [ ] Coordinate combat system implementation (awaiting 3/3 decision)
- [ ] Review card pool & enemy designs
- [ ] Support developer questions (Cursor IDE, Claude Code)
- [ ] Report weekly progress to Steve

### Lee.C (Content Manager)
- [ ] Blog post automation (GeekBrox skill)
- [ ] SNS content strategy implementation
- [ ] Narrative content alignment with game vision
- [ ] Content calendar planning
- [ ] Report weekly metrics to Steve

### Park.O (Ops Manager)
- [ ] Resource allocation & budget tracking ($200/month target)
- [ ] Team onboarding & documentation
- [ ] Infrastructure monitoring
- [ ] Model upgrade evaluations
- [ ] Report monthly budget status to Steve

## Weekly Review (Friday 3:00 PM PST)

All managers report to Steve:
1. **Progress**: Phase completion %, blockers, achievements
2. **Budget**: Monthly spend status, cost optimizations
3. **Next Week**: Priority tasks, risks, decisions needed
4. **Decisions**: Any items awaiting Steve's approval

## Documentation Maintenance

- **TEAM_WORKFLOWS.md**: Updated with role changes or new procedures
- **README files**: Maintained in each docs/ subfolder for navigation
- **Git commits**: All workflow changes documented with clear commit messages
- **Review cycle**: Monthly (end of March first)

## References

- **Organizational hierarchy**: See [docs/organization/AI_AGENTS_AND_WORKFLOW.md](../organization/AI_AGENTS_AND_WORKFLOW.md)
- **Phase 3 roadmap**: See [docs/planning/PHASE3_NEXT_TASKS.md](../planning/PHASE3_NEXT_TASKS.md)
- **Project structure**: See [docs/organization/PROJECT_STRUCTURE.md](../organization/PROJECT_STRUCTURE.md)

---

**Last Updated**: 2026-02-28 by Atlas  
**Budget**: $200/month | **Team**: 4 (Steve, Atlas, Kim.G, Lee.C, Park.O)  
**See also**: [docs/organization/](../organization/) for structural documentation
