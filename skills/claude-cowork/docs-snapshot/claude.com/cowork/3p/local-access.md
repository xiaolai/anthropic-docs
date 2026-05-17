> ## Documentation Index
> Fetch the complete documentation index at: https://claude.com/docs/llms.txt
> Use this file to discover all available pages before exploring further.

# Desktop and filesystem access

> How Cowork on 3P reads and writes files on the user's machine, and how to constrain it

Like standard [Cowork](/cowork/overview), Cowork on third-party (3P) works directly with files on the user's computer. Users attach one or more **workspace folders** to a session; the agent can then read, create, and modify files anywhere inside those folders, and run code against them inside the sandbox VM.

In Cowork on 3P, administrators can constrain which folders users are allowed to attach.

## Workspace folder allowlist

The `allowedWorkspaceFolders` configuration key restricts which paths users may attach as workspace folders.

| Value                                                | Behavior                                                                                                                                       |
| ---------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| Unset                                                | Unrestricted. Users can attach any folder they have OS-level access to, matching standard Cowork.                                              |
| `["~/Documents/Claude", "/Volumes/Shared/Projects"]` | Users may attach only folders **inside** one of the listed roots.                                                                              |
| `[]`                                                 | No folders may be attached. The agent can still create files in its own sandbox scratch space, but cannot read or write the user's filesystem. |

A leading `~` expands to the user's home directory, so a single profile can express per-user roots like `~/Documents/Claude` across the fleet.

The check is enforced against the **resolved** path, so symlinks and `..` traversal can't be used to escape an allowed root.

<Note>
  The allowlist controls what users can **attach**. Within an attached folder, the agent has full read/write access to every file the user's OS account can reach. To isolate sensitive data, keep it outside the allowed roots.
</Note>

## Network drives on Windows

Users can attach a mapped network drive (for example, `Z:\`) as a workspace folder through the folder picker. Raw UNC paths (`\\server\share`) are not supported; map the share to a drive letter first.

The agent can read, write, and search files on the network drive with its file tools. Shell commands, however, run in an isolated sandbox that cannot reach network shares. If a task needs to run a script or build against files on the network drive, ask the agent to copy the relevant files to a local folder first.

The agent cannot attach a network-drive path on its own; only the user can, through the folder picker. This is a security boundary.

On macOS, network mounts under `/Volumes/` are currently treated as local folders.