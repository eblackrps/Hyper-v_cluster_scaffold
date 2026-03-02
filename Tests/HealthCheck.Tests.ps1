#Requires -Modules Pester
BeforeAll {
    . "$PSScriptRoot\_Stubs.ps1"
    . "$PSScriptRoot\..\Private\Logging.ps1"
    . "$PSScriptRoot\..\Private\HealthCheck.ps1"
    Mock Write-HVLog { }
}

Describe "Get-HVClusterHealth" {
    Context "No cluster found" {
        It "Returns Critical with Score=0" {
            Mock Get-Cluster { $null }
            $result = Get-HVClusterHealth
            $result.Overall | Should -Be 'Critical'
            $result.Score   | Should -Be 0
        }
    }

    Context "All healthy" {
        BeforeEach {
            Mock Get-Cluster       { [PSCustomObject]@{ Name='TestCluster' } }
            Mock Get-ClusterNode   { @([PSCustomObject]@{ Name='N1'; State='Up' }, [PSCustomObject]@{ Name='N2'; State='Up' }) }
            Mock Get-ClusterGroup  { @([PSCustomObject]@{ Name='Core'; GroupType='CoreCluster'; State='Online'; OwnerNode=[PSCustomObject]@{Name='N1'} }) }
            Mock Get-ClusterSharedVolume { @() }
            Mock Get-ClusterQuorum { [PSCustomObject]@{ QuorumType='NodeAndDiskMajority'; QuorumResource='WitnessDisk' } }
        }

        It "Returns Healthy overall" {
            $result = Get-HVClusterHealth
            $result.Overall | Should -Be 'Healthy'
        }
        It "Score >= 80" {
            $result = Get-HVClusterHealth
            $result.Score | Should -BeGreaterOrEqual 80
        }
        It "Returns PSCustomObject with required properties" {
            $result = Get-HVClusterHealth
            $result.PSObject.Properties.Name | Should -Contain 'Nodes'
            $result.PSObject.Properties.Name | Should -Contain 'Resources'
            $result.PSObject.Properties.Name | Should -Contain 'Quorum'
            $result.PSObject.Properties.Name | Should -Contain 'Timestamp'
        }
    }

    Context "Node down" {
        It "Returns Warning or Critical when a node is down" {
            Mock Get-Cluster       { [PSCustomObject]@{ Name='TestCluster' } }
            Mock Get-ClusterNode   { @([PSCustomObject]@{ Name='N1'; State='Down' }, [PSCustomObject]@{ Name='N2'; State='Down' }) }
            Mock Get-ClusterGroup  { @() }
            Mock Get-ClusterSharedVolume { @() }
            Mock Get-ClusterQuorum { [PSCustomObject]@{ QuorumType='NodeMajority'; QuorumResource=$null } }

            $result = Get-HVClusterHealth
            $result.Overall | Should -BeIn @('Warning','Critical')
        }
    }
}
