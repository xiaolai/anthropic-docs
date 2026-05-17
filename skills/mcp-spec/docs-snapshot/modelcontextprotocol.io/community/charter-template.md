> ## Documentation Index
> Fetch the complete documentation index at: https://modelcontextprotocol.io/llms.txt
> Use this file to discover all available pages before exploring further.

# Group Charter Template

> Template for MCP Working Group and Interest Group charters.

Every MCP Working Group and Interest Group must maintain a charter document following this structure. Charters are stored at `docs/community/<group-name>/charter.mdx` in the [modelcontextprotocol repository](https://github.com/modelcontextprotocol/modelcontextprotocol) and added to `docs/docs.json`.

The charter captures information specific to your group. Governance rules — leadership requirements, decision-making process, meeting requirements, escalation paths — are defined in the [Working and Interest Groups](/community/working-interest-groups) documentation and apply automatically. Do not repeat them here.

Sections marked **(WG only)** are required for Working Groups and optional for Interest Groups.

<Note>
  Copy the markdown below into `docs/community/<group-name>/charter.mdx` and replace the placeholder text.
</Note>

***

```markdown theme={null}
---
title: <Group Name> Charter
description: Charter for the MCP <Group Name> <Working Group | Interest Group>.
---

## Group Type



**Working Group** | **Interest Group**

## Mission Statement



## Scope

### In Scope



### Out of Scope



### Related Groups



## Leadership



| Role | Name | Organization | GitHub | Term |
| ---- | ---- | ------------ | ------ | ---- |
|      |      |              |        |      |

## Authority & Decision Rights (WG only)



| Decision Type                       | Authority Level                                        |
| ----------------------------------- | ------------------------------------------------------ |
| Meeting logistics & scheduling      | WG Leads (autonomous)                                  |
| Proposal prioritization within WG   | WG Leads (autonomous)                                  |
| SEP triage & closure (in scope)     | WG Leads (autonomous, with documented rationale)       |
| Technical design within scope       | WG consensus                                           |
| Spec changes (additive)             | WG consensus → Core Maintainer approval                |
| Spec changes (breaking/fundamental) | WG consensus → Core Maintainer approval + wider review |
| Scope expansion                     | Core Maintainer approval required                      |
| WG Member approval                  | WG Member sponsors                                     |

## Membership



| Name | Organization | GitHub | Discord | Level |
| ---- | ------------ | ------ | ------- | ----- |
|      |              |        |         |       |

## Operations



| Meeting         | Frequency | Duration | Purpose                               |
| --------------- | --------- | -------- | ------------------------------------- |
| Working Session |           |          | Technical discussion, proposal review |
| Office Hours    |           |          | Open Q&A for newcomers and observers  |

## Deliverables & Success Metrics (WG only)



### Active Work Items

| Item          | Status                    | Target Date | Champion |
| ------------- | ------------------------- | ----------- | -------- |
| SEP-XXX: Name | Draft / Review / Approved |             |          |

### Success Criteria



## Changelog

| Date | Change |
| ---- | ------ |
|      |        |
```

***

## Example Mission Statements

**Working Group:**

> The Transport Working Group exists to evolve MCP's transport mechanisms to support diverse deployment scenarios—from local subprocess communication to horizontally-scaled cloud deployments—while maintaining protocol coherence and backward compatibility.

**Interest Group:**

> The Enterprise IG explores the challenges of deploying MCP in enterprise environments, gathering use cases and requirements to inform future specification work.