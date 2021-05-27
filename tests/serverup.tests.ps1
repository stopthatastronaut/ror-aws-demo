$global:DNSTarget = "rorawsdemo.takofukku.io" # keep this here, contexts are important

Function Install-IfNeeded {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        $modulename
    )
    begin {}
    process {
        if (-not (Get-Module -ListAvailable $_)) {
            Write-Output "Installing $_"
            Install-Module $_
        }
    }
    end {}
}

Set-PSRepository PSGallery -InstallationPolicy Trusted
@('awspowershell', 'pester') | Install-IfNeeded -Verbose

Import-Module AWSPowerShell


Describe "The server should be up" {

    It "Should respond on Port 80" {
        if ($null -eq $global:DNSTarget) { EXIT "BAD URL TO CHECK " }
        Invoke-WebRequest -uri http://$global:DNSTarget/ | Select-Object -expand Content | Should -Be "<h1>hello world</h1>"
    }

    It "Should reject port 3389" {
        $caught = $false
        try {
            new-object System.Net.Sockets.TcpClient("$global:DNSTarget", 3389)
        }
        catch {
            $caught = $true
        }

        $caught | Should -Be $true
    }

    It "Should not be reacahable on 22 from CI" {
        $ip = Invoke-RestMethod -uri http://canhazip.com/
        if ($ip -ne $env:TF_VAR_ssh_in_cidr) {
            $caught = $false
            try {
                new-object System.Net.Sockets.TcpClient("$global:DNSTarget", 22)
            }
            catch {
                $caught = $true
            }

            $caught | Should -Be $true
        }
        else {
            Write-Warning "Tests running from the SSH_IN_CIDR location, skipping with a warning"
            return true
        }
    }



}

Describe "SSH in and have a  look" {
    BeforeEach {
        # add this IP address to our sec group
        $thisip = Invoke-RestMethod http://canhazip.com/

        aws ec2 authorize-security-group-ingress --group-name rorinstancesec --protocol tcp --port 22 --cidr $thisip/32

    }

    It "Can be contacted via SSH" {
        {
            ssh ubuntu@$global:DNSTarget
            rails -v
            exit
        } | Should Not Throw
    } -skip    # need to figure out the IP we're coming from and add that to the Sec group. Tricky, but doable. Time consuming too.

    AfterEach {
        as ec2 revoke-security-group-ingress  --group-name rorinstancesec --protocol tcp --port 22 --cidr $thisip/32
    }
}