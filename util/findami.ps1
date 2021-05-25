Import-Module awspowershell

$filter = @(
    @{ name = "name"; value = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*" }

)

Get-EC2Image -region ap-southeast-2 -Filter $filter | Sort-Object CreationDate -Descending | Select-Object -First 1