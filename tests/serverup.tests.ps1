$DNSTarget = "ror-aws-demo.takofukku.io"

Describe "The server should be up" {
    It "Should respond on Port 80" {
        Invoke-WebRequest -uri http://$DNSTarget/ | Select-Object -expand Content | Should -Be "<h1>hello world</h1>"
    }

    It "Should reject port 3389" {
        new-object System.Net.Sockets.TcpClient("$DNSTarget", 3389)  | Should -Be $null
    }


}