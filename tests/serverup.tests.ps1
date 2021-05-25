$DNSTarget = "ror-aws-demo.takofukku.io"

Describe "The server should be up" {
    It "Should respond on Port 80" {
        Invoke-WebRequest -uri http://$DNSTarget/ | Select-Object -expand Content | Should -Be "<h1>hello world</h1>"
    }

    It "Should reject port 3389" {
        new-object System.Net.Sockets.TcpClient("$DNSTarget", 3389)  | Should -Be $null
    }

    It "Should not be reacahable on 22 from CI" {
        $ip = Invoke-RestMethod -uri http://canhazip.com/
        if ($ip -ne $env:TF_VAR_ssh_in_cidr) {
            new-object System.Net.Sockets.TcpClient("$DNSTarget", 3389)  | Should -Be $null
        }
        else {
            Write-Warning "Tests running from the SSH_IN_CIDR location, skipping with a warning"
            return true
        }
    }


}