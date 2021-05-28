ssh  -o "StrictHostKeyChecking=no" -i ~/rorawsdemo.pem ubuntu@rorawsdemo.takofukku.io 'sudo snap install powershell --classic; '
$rails = ssh  -o "StrictHostKeyChecking=no" -i ~/rorawsdemo.pem ubuntu@rorawsdemo.takofukku.io -E f.txt 'rails -v ' 2>&1
ssh  -o "StrictHostKeyChecking=no" -i ~/rorawsdemo.pem ubuntu@rorawsdemo.takofukku.io -E f.txt 'python -V ' 2>&1
Write-Host "Rails output was $rails" -ForegroundColor Yellow
ssh  -o "StrictHostKeyChecking=no" -i ~/rorawsdemo.pem ubuntu@rorawsdemo.takofukku.io
