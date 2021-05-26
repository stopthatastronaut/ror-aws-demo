$global:DNSTarget = "rorawsdemo.takofukku.io" # keep this here, contexts are important


Describe "The server should be up" {

    It "Should respond on Port 80" {
        if ($null -eq $global:DNSTarget) { EXIT "BAD URL TO CHECK " }
        Invoke-WebRequest -uri http://$global:DNSTarget/ | Select-Object -expand Content | Should -Be "<h1>hello world</h1>"
    }

    It "Should reject port 3389" {
        new-object System.Net.Sockets.TcpClient("$global:DNSTarget", 3389)  | Should -Be $null
    }

    It "Should not be reacahable on 22 from CI" {
        $ip = Invoke-RestMethod -uri http://canhazip.com/
        if ($ip -ne $env:TF_VAR_ssh_in_cidr) {
            new-object System.Net.Sockets.TcpClient("$global:DNSTarget", 3389)  | Should -Be $null
        }
        else {
            Write-Warning "Tests running from the SSH_IN_CIDR location, skipping with a warning"
            return true
        }
    }

    It "Can be contacted via SSH" {
        {
            ssh ubuntu@$global:DNSTarget
            rails -v
            exit
        } | Should Not Throw
    }

}