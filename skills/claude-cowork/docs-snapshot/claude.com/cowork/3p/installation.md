> ## Documentation Index
> Fetch the complete documentation index at: https://claude.com/docs/llms.txt
> Use this file to discover all available pages before exploring further.

# Installation and setup

> Roll out Cowork on 3P to your organization, from a single evaluation machine to a fleet-wide MDM deployment

Cowork on third-party (3P) is the standard Claude Desktop application plus a managed configuration that activates third-party inference mode. You distribute the regular Claude Desktop installer and apply the configuration through your existing device-management tooling.

## Recommended rollout

For most organizations, we recommend a three-stage rollout:

<Steps>
  <Step title="Evaluate on a single machine">
    An admin installs Claude Desktop on their own device and uses the in-app configuration window to build and test a working configuration against your inference provider.
  </Step>

  <Step title="Allow required network egress">
    Open the hostnames your configuration requires on your perimeter firewall. The configuration window lists them for the exact settings you've chosen.
  </Step>

  <Step title="Export and deploy via MDM">
    From the configuration window, export the validated configuration as a `.mobileconfig` (macOS) or `.reg` (Windows) file and distribute it through Jamf, Intune, Group Policy, or your MDM of choice.
  </Step>

  <Step title="Distribute the app">
    Push the Claude Desktop installer to enrolled devices. When the app launches and finds a managed configuration, it enters 3P mode automatically with no user sign-in or setup required.
  </Step>
</Steps>

Deploying the configuration before the app means end users open Claude for the first time and land directly in Cowork, with no opportunity to sign in to claude.ai by mistake.

## Admin installation

### 1. Install Claude Desktop

Download the installer for your platform from [claude.com/download](https://claude.com/download).

| Platform | Installer | Notes                                                       |
| -------- | --------- | ----------------------------------------------------------- |
| macOS    | `.dmg`    | Drag **Claude.app** to Applications                         |
| Windows  | `.msix`   | Supports per-machine provisioning for enterprise deployment |

### 2. Build a configuration in the app

Launch Claude Desktop. **Do not sign in or create an Anthropic account** — stay on the login screen.

<Tabs>
  <Tab title="macOS">
    From the macOS menu bar at the top of the screen:

    1. Go to **Help → Troubleshooting → Enable Developer Mode** to reveal the Developer menu.
    2. Then go to **Developer → Configure third-party inference** to open the configuration window.
  </Tab>

  <Tab title="Windows">
    Open the application menu (☰) in the top-left of the Claude login screen:

    1. Go to **Help → Troubleshooting → Enable Developer Mode** to reveal the Developer menu.
    2. Then go to **Developer → Configure third-party inference** to open the configuration window.
  </Tab>
</Tabs>

The window is organized into seven sections in the left sidebar. Work through them in order; each maps to a group of [configuration keys](/cowork/3p/configuration), and the window validates values as you enter them.

<table>
  <thead>
    <tr><th>Section</th><th>What you set</th></tr>
  </thead>

  <tbody>
    <tr>
      <td><strong>Connection</strong></td>

      <td>
        <ul>
          <li>Inference provider (Gateway, Vertex, Bedrock, or Foundry) and its credentials</li>
          <li>Model list</li>
          <li>Organization UUID</li>
          <li>Optional credential-helper script</li>
        </ul>
      </td>
    </tr>

    <tr>
      <td><strong>Sandbox & workspace</strong></td>

      <td>
        <ul>
          <li>Whether the Code tab is shown</li>
          <li>Allowed egress hosts for the sandbox</li>
          <li>Disabled built-in tools</li>
          <li>Allowed workspace folders</li>
        </ul>
      </td>
    </tr>

    <tr>
      <td><strong>Connectors & extensions</strong></td>

      <td>
        <ul>
          <li>Managed MCP servers pushed to all users</li>
          <li>Whether users can add their own local MCP servers</li>
          <li>Whether desktop extensions (<code>.mcpb</code>) are allowed</li>
          <li>Whether the extension directory is shown</li>
          <li>Whether unsigned extensions are rejected</li>
        </ul>
      </td>
    </tr>

    <tr>
      <td><strong>Telemetry & updates</strong></td>

      <td>
        <ul>
          <li>OpenTelemetry collector endpoint</li>
          <li>Whether auto-updates are blocked, and the enforcement window if not</li>
          <li>The three Anthropic-bound telemetry toggles (essential, nonessential, nonessential services)</li>
        </ul>
      </td>
    </tr>

    <tr>
      <td><strong>Usage limits</strong></td>

      <td>
        <ul>
          <li>Per-device token cap and its window length</li>
        </ul>
      </td>
    </tr>

    <tr>
      <td><strong>Plugins & skills</strong></td>

      <td>
        <ul>
          <li>Shows the org-plugins folder path for your platform</li>
          <li>Plugins are distributed by mounting bundles to that folder via your MDM, not through this window</li>
        </ul>
      </td>
    </tr>

    <tr>
      <td><strong>Egress Requirements</strong></td>

      <td>
        <ul>
          <li>A read-only firewall allowlist derived from everything you've entered above, grouped by feature</li>
          <li><strong>Copy hostnames</strong>, <strong>Download .txt</strong>, and <strong>Test connectivity</strong> actions</li>
        </ul>
      </td>
    </tr>
  </tbody>
</table>

The configuration picker in the top-right shows which saved configuration you're editing and whether it's the one currently applied. On a managed device it indicates the configuration is organization-managed, and every section shows a banner directing users to their IT administrator.

The configuration window is the recommended way to author configurations. It validates field formats, knows which keys each provider requires, and stays current as new keys are added.

<Note>
  When a managed (MDM-delivered) configuration is already present on the device, the configuration window opens read-only. It shows what the admin deployed but won't let the user change or override it. To author a new configuration, use a device without a managed profile, or temporarily remove the profile.
</Note>

### 3. Export for MDM

Once your configuration tests successfully, click **Export** and choose a format:

| Format          | Platform | Deploy with                                                                                                     |
| --------------- | -------- | --------------------------------------------------------------------------------------------------------------- |
| `.mobileconfig` | macOS    | Jamf, Kandji, Mosyle, Workspace ONE, or any Apple MDM                                                           |
| `.reg`          | Windows  | Group Policy (import into a GPO), Intune (via custom ADMX or script), or any MDM that can write registry policy |

The two actions in the configuration window do different things:

* **Apply locally** writes the selected configuration to your own machine's Claude settings and relaunches the app, so you can test it end to end before deploying it.
* **Export** writes a `.mobileconfig` or `.reg` file and leaves your local settings untouched.

#### Creating profiles for multiple user groups

Many organizations deploy distinct configurations to different populations: for example, a permissive profile for an engineering pilot group and a restricted profile for the broader rollout, or per-region profiles that point at different inference endpoints.

The configuration window can hold multiple named configurations. Use the picker in the top-right of the window:

* **New configuration** creates an empty configuration.
* **Duplicate** copies the current configuration as a starting point for a variant.
* **Rename** and **Delete** manage the list.
* **Reveal in Finder** opens the on-disk location where saved configurations are stored.

Selecting a configuration in the picker loads it for editing; the **applied** badge marks the one currently active on your machine. **Apply locally** and **Export** each act on whichever configuration is selected, so you can test each one locally and export them independently.

In your MDM, scope each exported profile to the corresponding device or user group. Targeting is handled by your MDM's assignment rules; the configuration name is for your authoring workflow and is not part of the deployed profile.

### 4. Allow required network egress

The hosts the app needs to reach depend on the configuration you built: your inference provider's endpoint is always required, and each telemetry, update, and service setting you leave enabled adds its own hosts. The configuration window shows the exact allowlist for your settings and can export it as a text file for your network team.

Open these hosts on your perimeter firewall before rolling out to devices. See [Telemetry and egress](/cowork/3p/telemetry#required-egress-paths) for the full list of hosts grouped by the setting that controls each one, and for the distinction between the perimeter firewall and the in-app sandbox allowlist.

### 5. Deploy the configuration

Push the exported configuration through your MDM. The app reads from these locations:

<Tabs>
  <Tab title="macOS">
    | Source             | Path                                                                       | Precedence |
    | ------------------ | -------------------------------------------------------------------------- | ---------- |
    | Managed (per-user) | `/Library/Managed Preferences/<user>/com.anthropic.claudefordesktop.plist` | Highest    |
    | Managed (machine)  | `/Library/Managed Preferences/com.anthropic.claudefordesktop.plist`        |            |
    | Local (user)       | `~/Library/Application Support/Claude-3p/configLibrary/`                   | Lowest     |

    A `.mobileconfig` profile delivered by MDM lands in the Managed Preferences locations automatically. Both managed paths are read; where a key appears in both, the per-user value wins.
  </Tab>

  <Tab title="Windows">
    | Source         | Path                                      | Precedence |
    | -------------- | ----------------------------------------- | ---------- |
    | Machine policy | `HKLM\SOFTWARE\Policies\Claude`           | Highest    |
    | User policy    | `HKCU\SOFTWARE\Policies\Claude`           |            |
    | Local (user)   | `%LOCALAPPDATA%\Claude-3p\configLibrary\` | Lowest     |

    A Group Policy Object or Intune configuration profile writes to the registry policy paths. Both hives are read; where a key appears in both, the machine (`HKLM`) value wins.
  </Tab>
</Tabs>

When **any** managed source is present, it takes effect and the in-app configuration window becomes read-only. Locally authored values in `configLibrary/` are ignored.

### 6. Distribute the app

Deploy the Claude Desktop installer to enrolled devices using your standard software-distribution mechanism. On launch, the app reads the managed configuration, detects the configured inference provider and credentials, and the sign-in screen offers users the option to start in Cowork on 3P.

### 7. Configure the Code tab (if enabled)

Anthropic is working on achieving settings parity between the Cowork and Code tabs. Today, some Cowork on 3P configuration keys do not yet propagate identically to Code-tab sessions. To configure the Code tab directly, deploy a Claude Code `managed-settings.json` alongside your profile, or disable the Code tab with `isClaudeCodeForDesktopEnabled: false`. See [Code tab](/cowork/3p/code).

### 8. Deploy organization plugins (optional)

If you're distributing [organization plugins](/cowork/3p/extensions#organization-plugins-admin), push the plugin bundles to the org-plugins directory on each device alongside the configuration profile. Plugins are picked up at the next app launch.

## End-user installation

For pilots, evaluations, or organizations that don't use MDM, individual users can configure 3P mode themselves.

1. Install Claude Desktop from [claude.com/download](https://claude.com/download).
2. Launch the app. **Do not sign in or create an Anthropic account.** From the macOS menu bar (or on Windows, the application menu ☰ in the top-left of the login screen), go to **Help → Troubleshooting → Enable Developer Mode**, then **Developer → Configure third-party inference**.
3. Enter the provider, endpoint, and credential values supplied by your administrator.
4. Click **Apply locally**. The app relaunches and the sign-in screen now offers the option to start in Cowork on 3P using the configuration you entered.

The configuration is written to the application's local config file and applies only to that device and user account. It can be edited from the same window at any time. To return to standard Claude Desktop, choose the Anthropic sign-in option on the sign-in screen instead.

## Verifying the deployment

On any configured device, open Claude Desktop and go to **Help → Troubleshooting → Copy Managed Configuration Report**. This copies a summary showing which keys were detected, where they were read from (managed profile vs. user store), and whether the inference credentials validated successfully. Secret values are redacted.

If the app shows the standard claude.ai sign-in screen instead of Cowork, the configuration was not read. Common causes:

* `inferenceProvider` is missing, misspelled, or set to an unrecognized value
* The configuration was applied while the app was running (fully quit and relaunch)
* The configuration was written to the local config file but you're checking the managed location (or vice versa)
* A required key for the chosen provider is missing; check **Help → Troubleshooting** or the application log at `~/Library/Logs/Claude/main.log` (macOS) / `%APPDATA%\Claude\logs\main.log` (Windows)

## Troubleshooting

If you're experiencing technical issues with installation or setup, generate a diagnostic report and share it with Anthropic.

On the affected machine, go to **Help → Troubleshooting → Generate Diagnostic Report** in the menu bar, choose a save location, and send the resulting folder to your Anthropic representative.

Please generate the diagnostic before requesting support. The report contains the configuration state, application logs, and environment details needed to investigate, and does not include any user data or conversation content.

## Endpoint security software

If your organization runs binary-authorization or EDR software (such as [Santa](https://santa.dev), CrowdStrike Falcon, or Microsoft Defender ASR) with path-based deny rules, the Cowork agent helper may be blocked from launching. The symptom is that Claude Desktop opens normally and reads the managed configuration, but Cowork sessions fail to start.

The agent helper is a signed binary that Claude Desktop installs under its user-data directory. **Allowlist by signing identity rather than path** so the rule survives version updates.

**macOS**

```
~/Library/Application Support/Claude-3p/claude-code/<version>/claude.app/Contents/MacOS/claude
```

The helper is Developer ID signed and notarized:

* Team ID: `Q6L2SF6YDW` (Anthropic PBC)
* Signing ID: `com.anthropic.claude-code`

For Santa, a `TEAMID` allow rule for `Q6L2SF6YDW` covers the helper across version updates. Standard (non-3P) installs use `~/Library/Application Support/Claude/` with the same subpath.

**Windows**

```
%LOCALAPPDATA%\Claude-3p\claude-code\<version>\claude.exe
```

The helper is Authenticode-signed with publisher `Anthropic, PBC`. For Defender ASR or AppLocker, allowlist by publisher rather than path. Standard installs use `%APPDATA%\Claude\` with the same subpath.

## Updates

By default, Claude Desktop checks Anthropic's update server and applies updates automatically. In 3P deployments you can:

* **Leave auto-update enabled** (recommended) so fixes reach users without IT intervention. Use `autoUpdaterEnforcementHours` to bound how long users can defer a pending update.
* **Disable auto-update** (`disableAutoUpdates`) and redistribute new builds through your MDM on your own cadence. This is required for air-gapped environments but means your IT team owns the update pipeline.

See [Telemetry and egress](/cowork/3p/telemetry) for the network paths the updater uses.