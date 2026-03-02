@{
    RootModule        = 'HyperVClusterPlatform.psm1'
    ModuleVersion     = '20.0.0'
    GUID              = 'b5c96ad8-5ffb-4f70-9e3c-3e0ff1f31d1f'
    Author            = 'E. Black'
    CompanyName       = ''
    Copyright         = '(c) 2026 E. Black. All rights reserved.'
    Description       = 'Hyper-V Cluster deployment, compliance, and fleet management platform (Audit/Enforce/Remediate). Supports Windows Server 2022 and 2025. Includes network automation, VM placement, storage, health monitoring, alerting, secret management, fleet orchestration, live migration, DR, and production certification.'
    PowerShellVersion = '5.1'

    # FailoverClusters and Hyper-V are validated at runtime by Test-HVPrerequisites.
    RequiredModules   = @()

    FunctionsToExport = @(
        'Invoke-HVClusterPlatform'
        'Invoke-HVClusterFleet'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()

    FileList          = @(
        'HyperVClusterPlatform.psm1'
        'Public\Invoke-HVClusterPlatform.ps1'
        'Public\Invoke-HVClusterFleet.ps1'
        'Private\Logging.ps1'
        'Private\DesiredState.ps1'
        'Private\Preflight.ps1'
        'Private\NodeValidation.ps1'
        'Private\Snapshot.ps1'
        'Private\DriftEngine.ps1'
        'Private\ComplianceReport.ps1'
        'Private\Enforcement.ps1'
        'Private\Rollback.ps1'
        'Private\Configuration.ps1'
        'Private\NetworkConfig.ps1'
        'Private\VMPlacement.ps1'
        'Private\StorageConfig.ps1'
        'Private\HealthCheck.ps1'
        'Private\Alerting.ps1'
        'Private\SecretManagement.ps1'
        'Private\TelemetryExport.ps1'
        'Private\LiveMigration.ps1'
        'Private\DisasterRecovery.ps1'
        'Private\CertificationSuite.ps1'
    )

    PrivateData = @{
        PSData = @{
            Tags         = @('Hyper-V','FailoverClusters','Compliance','Automation','DSC',
                             'WS2022','WS2025','LiveMigration','DisasterRecovery','FleetManagement',
                             'HealthMonitoring','SecretManagement','Certification')
            LicenseUri   = 'https://github.com/eblackrps/Hyper-v_cluster_scaffold/blob/main/LICENSE'
            ProjectUri   = 'https://github.com/eblackrps/Hyper-v_cluster_scaffold'
            ReleaseNotes = @'
v20.0.0 — Full platform release (v9-v20 combined):
  - v9:  NetworkConfig     — adapter classification, cluster network roles, live migration networks
  - v10: VMPlacement       — preferred owners, anti-affinity groups, placement drift scoring
  - v11: DSC resource      — full Get/Test/Set-TargetResource, updated schema.mof
  - v12: StorageConfig     — CSV enumeration, add/rename CSVs, storage drift scoring
  - v13: HealthCheck       — structured cluster health (Healthy/Warning/Critical), per-node/CSV/VM
  - v13: Alerting          — email, Teams Adaptive Card, Slack webhook, Windows Event Log
  - v14: SecretManagement  — SecretManagement vault, CredentialManager fallback, Resolve-HVConfigSecrets
  - v15: Fleet             — Invoke-HVClusterFleet, parallel PS7+ execution, fleet HTML report
  - v15: TelemetryExport   — NDJSON structured events, drift trend analysis
  - v16: ComplianceReport  — Chart.js trend chart, per-check detail table, JSON telemetry alongside HTML
  - v17: Scripts           — Update-ModuleVersion.ps1, New-Release.ps1 for PSGallery/GitHub automation
  - v18: LiveMigration     — readiness checks, Kerberos/CredSSP config, live migration orchestration
  - v19: DisasterRecovery  — DR snapshot with Hyper-V Replica status, readiness checks, failover orchestration
  - v20: CertificationSuite — 10-domain production certification with HTML report
'@
        }
    }
}
