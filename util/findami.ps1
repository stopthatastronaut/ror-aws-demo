Import-Module awspowershell

$filter = @(
    @{ name = "name"; value = "*Ubuntu*" }
    @{ name = "image-owner"; value = "!aws-marketplace" }

)

Get-EC2Image -region ap-southeast-2 -Filter $filter