Import-Module awspowershell

$keyname = "rorawsdemo"

$key = New-EC2KeyPair -KeyName $keyname -Region ap-southeast-2

$key.keymaterial | Out-File ~/$keyname.pem