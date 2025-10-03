param (
    [Parameter(Mandatory=$true, Position = 0)][string]$destination,
    [int]$port = 80
)

[string]$httpServerFilePath = "http-file-server.exe"
[string]$defaultSshArgs = "-i `"$($env:USERPROFILE)\.ssh\id_rsa`""

$httpServerProcess = [System.Diagnostics.Process]::new()
$httpServerProcess.StartInfo.FileName = $httpServerFilePath
$httpServerProcess.StartInfo.Arguments = "-p ${port}"
$httpServerProcess.StartInfo.CreateNoWindow = $true
$httpServerProcess.StartInfo.WindowStyle = "Hidden"

Write-Host "Starting http server"

$null = $httpServerProcess.Start()

$rawUi = (Get-Host).UI.RawUI

[System.Threading.ThreadStart]$sshThreadHandler = {
	while ($true) {
		Write-Host "Starting ssh port forwarding"
		
		$sshProcess = [System.Diagnostics.Process]::new()
		$sshProcess.StartInfo.FileName = "ssh"
		$sshProcess.StartInfo.Arguments = "${defaultSshArgs} ${destination} `"kill `$(lsof -t -i:${port})`""
		$sshProcess.StartInfo.CreateNoWindow = $true
		$sshProcess.StartInfo.WindowStyle = "Hidden"
		$sshProcess.StartInfo.UseShellExecute = $false
		
		$sshProcess.Start()
		$sshProcess.WaitForExit()
		
		$sshProcess = [System.Diagnostics.Process]::new()
		$sshProcess.StartInfo.FileName = "ssh"
		$sshProcess.StartInfo.Arguments = "-NTC -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes -R ${port}:localhost:${port} ${defaultSshArgs} ${destination}"
		$sshProcess.StartInfo.CreateNoWindow = $true
		$sshProcess.StartInfo.WindowStyle = "Hidden"
		$sshProcess.StartInfo.UseShellExecute = $false
		
		$sshProcess.Start()
		$sshProcess.WaitForExit()

		Timeout /T 10
	}
}

$sshThread = [System.Threading.Thread]::new($sshThreadHandler)
$sshThread.SetApartmentState([System.Threading.ApartmentState]::STA)
$sshThread.Start()

try {
	while ($true) {
		Write-Host "New input"
		$rawUi.ReadKey('NoEcho,IncludeKeyDown')
	}
} finally {
	Write-Host "Bye"
	
	$httpServerProcess.Kill()
	$sshThread.Abort()
}