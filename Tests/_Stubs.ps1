# Tests/_Stubs.ps1
# Stub definitions for cmdlets that come from optional Windows Server modules
# (FailoverClusters, Hyper-V, ServerManager). These stubs let Pester create Mocks
# even when the modules are not installed on the test machine.
# Parameter declarations match what the production code actually passes.

# ── FailoverClusters ─────────────────────────────────────────────────────────
if (-not (Get-Command Get-Cluster              -ErrorAction SilentlyContinue)) { function Get-Cluster              { [CmdletBinding()] param([string]$Name) } }
if (-not (Get-Command Get-ClusterNode          -ErrorAction SilentlyContinue)) { function Get-ClusterNode          { [CmdletBinding()] param([string]$Name,[string]$Cluster) } }
if (-not (Get-Command Get-ClusterQuorum        -ErrorAction SilentlyContinue)) { function Get-ClusterQuorum        { [CmdletBinding()] param([string]$Cluster) } }
if (-not (Get-Command Get-ClusterGroup         -ErrorAction SilentlyContinue)) { function Get-ClusterGroup         { [CmdletBinding()] param([string]$Name,[string]$Cluster) } }
if (-not (Get-Command Get-ClusterGroupProperty -ErrorAction SilentlyContinue)) { function Get-ClusterGroupProperty { [CmdletBinding()] param([string]$Name,[Parameter(ValueFromPipeline)]$InputObject) process { } } }
if (-not (Get-Command Get-ClusterNetwork       -ErrorAction SilentlyContinue)) { function Get-ClusterNetwork       { [CmdletBinding()] param([string]$Cluster) } }
if (-not (Get-Command Get-ClusterResource      -ErrorAction SilentlyContinue)) { function Get-ClusterResource      { [CmdletBinding()] param([string]$Name,[string]$Cluster) } }
if (-not (Get-Command Get-ClusterSharedVolume  -ErrorAction SilentlyContinue)) { function Get-ClusterSharedVolume  { [CmdletBinding()] param([string]$Name,[string]$Cluster) } }
if (-not (Get-Command Get-ClusterSharedVolumeState -ErrorAction SilentlyContinue)) { function Get-ClusterSharedVolumeState { [CmdletBinding()] param([Parameter(ValueFromPipeline)]$InputObject) process { } } }
if (-not (Get-Command Add-ClusterSharedVolume  -ErrorAction SilentlyContinue)) { function Add-ClusterSharedVolume  { [CmdletBinding()] param([string]$Name) } }
if (-not (Get-Command Add-ClusterDisk          -ErrorAction SilentlyContinue)) { function Add-ClusterDisk          { [CmdletBinding()] param([string]$Name) } }
if (-not (Get-Command New-Cluster              -ErrorAction SilentlyContinue)) { function New-Cluster              { [CmdletBinding()] param([string]$Name,[string[]]$Node,[string]$StaticAddress,[switch]$Force,[switch]$NoStorage) } }
if (-not (Get-Command Add-ClusterNode          -ErrorAction SilentlyContinue)) { function Add-ClusterNode          { [CmdletBinding()] param([string]$Name,[switch]$NoStorage) } }
if (-not (Get-Command Remove-Cluster           -ErrorAction SilentlyContinue)) { function Remove-Cluster           { [CmdletBinding()] param([string]$Cluster,[switch]$Force,[switch]$CleanUpAD) } }
if (-not (Get-Command Remove-ClusterNode       -ErrorAction SilentlyContinue)) { function Remove-ClusterNode       { [CmdletBinding()] param([string]$Name,[string]$Cluster,[switch]$Force,[switch]$Wait) } }
if (-not (Get-Command Set-ClusterQuorum        -ErrorAction SilentlyContinue)) { function Set-ClusterQuorum        { [CmdletBinding()] param([string]$Cluster,[switch]$NodeMajority,[switch]$NodeAndDiskMajority,[string]$DiskWitness,[switch]$NodeAndFileShareMajority,[string]$FileShareWitness,[switch]$CloudWitness,[string]$AccountName,[string]$AccountKey,[string]$Endpoint) } }
if (-not (Get-Command Set-ClusterOwnerNode     -ErrorAction SilentlyContinue)) { function Set-ClusterOwnerNode     { [CmdletBinding()] param([string]$Group,[string[]]$Owners) } }
if (-not (Get-Command Move-ClusterVirtualMachineRole -ErrorAction SilentlyContinue)) { function Move-ClusterVirtualMachineRole { [CmdletBinding()] param([string]$Name,[string]$Node) } }
if (-not (Get-Command Suspend-ClusterNode      -ErrorAction SilentlyContinue)) { function Suspend-ClusterNode      { [CmdletBinding()] param([string]$Name,[switch]$Drain) } }

# ── Hyper-V ───────────────────────────────────────────────────────────────────
if (-not (Get-Command Get-VM                   -ErrorAction SilentlyContinue)) { function Get-VM                   { [CmdletBinding()] param([string]$Name,[string]$ComputerName) } }
if (-not (Get-Command Get-VMHost               -ErrorAction SilentlyContinue)) { function Get-VMHost               { [CmdletBinding()] param([string]$ComputerName) } }
if (-not (Get-Command Set-VMHost               -ErrorAction SilentlyContinue)) { function Set-VMHost               { [CmdletBinding()] param([string]$ComputerName,[bool]$VirtualMachineMigrationEnabled,[string]$VirtualMachineMigrationAuthenticationType,[int]$MaximumVirtualMachineMigrations) } }
if (-not (Get-Command Get-VMHostSupportedVersion -ErrorAction SilentlyContinue)) { function Get-VMHostSupportedVersion { [CmdletBinding()] param([string]$ComputerName) } }
if (-not (Get-Command Measure-VMReplication    -ErrorAction SilentlyContinue)) { function Measure-VMReplication    { [CmdletBinding()] param([string]$VMName,[string]$ComputerName) } }

# ── ServerManager ─────────────────────────────────────────────────────────────
if (-not (Get-Command Get-WindowsFeature       -ErrorAction SilentlyContinue)) { function Get-WindowsFeature       { [CmdletBinding()] param([string]$Name,[string]$ComputerName) } }
if (-not (Get-Command Install-WindowsFeature   -ErrorAction SilentlyContinue)) { function Install-WindowsFeature   { [CmdletBinding()] param([string]$Name,[switch]$IncludeManagementTools,[switch]$IncludeAllSubFeature) } }

# ── SecretManagement / CredentialManager ─────────────────────────────────────
if (-not (Get-Command Get-Secret               -ErrorAction SilentlyContinue)) { function Get-Secret               { [CmdletBinding()] param([string]$Name,[string]$Vault,[switch]$AsSecureString) } }
if (-not (Get-Command Get-StoredCredential     -ErrorAction SilentlyContinue)) { function Get-StoredCredential     { [CmdletBinding()] param([string]$Target) } }

# ── Networking ───────────────────────────────────────────────────────────────
if (-not (Get-Command Get-NetAdapter           -ErrorAction SilentlyContinue)) { function Get-NetAdapter           { [CmdletBinding()] param([string]$Name) } }
if (-not (Get-Command Get-NetAdapterBinding    -ErrorAction SilentlyContinue)) { function Get-NetAdapterBinding    { [CmdletBinding()] param([string]$Name) } }
if (-not (Get-Command Set-ClusterNetworkInterface -ErrorAction SilentlyContinue)) { function Set-ClusterNetworkInterface { [CmdletBinding()] param([string]$Name) } }

# ── Event Log ─────────────────────────────────────────────────────────────────
if (-not (Get-Command Write-EventLog           -ErrorAction SilentlyContinue)) { function Write-EventLog           { [CmdletBinding()] param([string]$LogName,[string]$Source,[string]$EntryType,[int]$EventId,[string]$Message) } }
if (-not (Get-Command New-EventLog             -ErrorAction SilentlyContinue)) { function New-EventLog             { [CmdletBinding()] param([string]$LogName,[string]$Source) } }
