#Requires -Modules Pester
BeforeAll {
    . "$PSScriptRoot\_Stubs.ps1"
    . "$PSScriptRoot\..\Private\Logging.ps1"
    . "$PSScriptRoot\..\Private\StorageConfig.ps1"
    Mock Write-HVLog { }
}

Describe "Get-HVCSVState" {
    It "Returns empty array when no CSVs exist" {
        Mock Get-ClusterSharedVolume { @() }
        $result = Get-HVCSVState
        @($result).Count | Should -Be 0
    }

    It "Returns one entry per CSV" {
        $fakeCSV = [PSCustomObject]@{
            Name      = 'Cluster Disk 1'
            State     = 'Online'
            OwnerNode = [PSCustomObject]@{ Name='NODE1' }
            SharedVolumeInfo = @()
        }
        Mock Get-ClusterSharedVolume   { @($fakeCSV) }
        Mock Get-ClusterSharedVolumeState { @([PSCustomObject]@{ VolumeFriendlyName='C:\ClusterStorage\Volume1'; StateInfo='Direct' }) }

        $result = Get-HVCSVState
        @($result).Count | Should -Be 1
        $result[0].Name | Should -Be 'Cluster Disk 1'
    }
}

Describe "Get-HVStorageDrift" {
    Context "No requirements set" {
        It "Returns Score=0 with no desired constraints" {
            Mock Get-ClusterSharedVolume { @() }
            $result = Get-HVStorageDrift
            $result.Score | Should -Be 0
        }
    }

    Context "CSV count requirement" {
        It "Scores drift when not enough CSVs" {
            Mock Get-ClusterSharedVolume { @() }
            $result = Get-HVStorageDrift -DesiredCSVCount 2
            $result.Score | Should -BeGreaterThan 0
            ($result.Details | Where-Object { $_ -match 'count' }) | Should -Not -BeNullOrEmpty
        }
        It "Returns Score=0 when CSV count is met" {
            $csvs = 1..2 | ForEach-Object { [PSCustomObject]@{ Name="Disk$_"; State='Online'; OwnerNode=[PSCustomObject]@{Name='N1'}; SharedVolumeInfo=@() } }
            Mock Get-ClusterSharedVolume   { $csvs }
            Mock Get-ClusterSharedVolumeState { @([PSCustomObject]@{ VolumeFriendlyName='Vol'; StateInfo='Direct' }) }
            $result = Get-HVStorageDrift -DesiredCSVCount 2
            $result.Score | Should -Be 0
        }
    }

    Context "Unhealthy CSV" {
        It "Adds score for offline CSV" {
            $csv = [PSCustomObject]@{ Name='Disk1'; State='Failed'; OwnerNode=[PSCustomObject]@{Name='N1'}; SharedVolumeInfo=@() }
            Mock Get-ClusterSharedVolume   { @($csv) }
            Mock Get-ClusterSharedVolumeState { @() }
            $result = Get-HVStorageDrift
            $result.Score | Should -BeGreaterThan 0
        }
    }
}
