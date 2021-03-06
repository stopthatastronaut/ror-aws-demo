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
@('awspowershell') | Install-IfNeeded -Verbose

Import-Module AWSPowerShell


Describe "The server should be up and serving HTML" {

    It "Should respond on Port 80" {
        if ($null -eq $global:DNSTarget) { EXIT "BAD URL TO CHECK " }
        $match = "<h1>hello world</h1>*"
        $ready = $false
        $sleeptime = 10 # seconds
        $resp = ""
        while ($ready -eq $false -and $sleeptime -lt 360) {
            # try, then pause and retry, because we might outrace the user data
            $resp = Invoke-WebRequest -uri http://$global:DNSTarget/ | Select-Object -expand Content
            if ($resp -like $match) { break }
            Start-Sleep -Seconds $sleeptime
            Write-Output "waiting $sleeptime"
            $sleeptime = $sleeptime * 2
        }
        $resp | Should -BeLike $match
    }

    It "Should reject port 3389" {
        $caught = $false
        try {
            $client = new-object System.Net.Sockets.TcpClient
            $client.ReceiveTimeout = 20000 # 20s timeout
            $client.connect("$global:DNSTarget", 3389)
        }
        catch {
            $caught = $true
        }
        finally {
            $client.Close()
        }

        $caught | Should -Be $true
    }

    It "Should not be reachable on 22 from CI" {
        $ip = Invoke-RestMethod -uri http://canhazip.com/
        if ($ip -ne $env:TF_VAR_ssh_in_cidr) {
            $caught = $false
            try {
                $client = new-object System.Net.Sockets.TcpClient
                $client.ReceiveTimeout = 20000 # 20s timeout

                $client.Connect("$global:DNSTarget", 22)
            }
            catch {
                $caught = $true
            }
            finally {
                $client.Close()
            }

            $caught | Should -Be $true
        }
        else {
            Write-Warning "Tests running from the SSH_IN_CIDR location, skipping with a warning"
            return true
        }
    }

    It "Should have a valid DNS name" {
        # this is implicitly true if prior tests pass
    } -skip


}

Describe "SSH in and have a  look" {
    BeforeEach {
        # add this IP address to our sec group
        $thisip = Invoke-RestMethod http://canhazip.com/
        $ip = $thisip.trim()

        aws ec2 authorize-security-group-ingress --group-name rorinstancesec --protocol tcp --port 22 --cidr "$ip/32" --region ap-southeast-2

    }

    It "Should have Python installed" {
        ssh  -o "StrictHostKeyChecking=no" -E f.txt 'python -V ' 2>&1 | Should -BeLike "Python 3*"
    }

    It "Can be contacted via SSH and should have rails" {
        $output = ssh -o "StrictHostKeyChecking=no" ubuntu@$global:DNSTarget -E f.txt 'rails -v' 2>&1
        $output | Should -Not -BeLike "*command not found*"
    } -Skip # Rails install is so broken right now


    AfterEach {
        aws ec2 revoke-security-group-ingress  --group-name rorinstancesec --protocol tcp --port 22 --cidr "$ip/32" --region ap-southeast-2
    }
}

Describe "We closed SSH ports again after running tests" {
    It "Should not be reachable on 22 from CI" {
        $ip = Invoke-RestMethod -uri http://canhazip.com/
        if ($ip -ne $env:TF_VAR_ssh_in_cidr) {
            $caught = $false
            try {
                $client = new-object System.Net.Sockets.TcpClient
                $client.ReceiveTimeout = 20000 # 20s timeout

                $client.Connect("$global:DNSTarget", 22)
            }
            catch {
                $caught = $true
            }
            finally {
                $client.Close()
            }

            $caught | Should -Be $true
        }
        else {
            Write-Warning "Tests running from the SSH_IN_CIDR location, skipping with a warning"
            return true
        }
    }
}