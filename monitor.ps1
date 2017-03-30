Unregister-Event -SourceIdentifier FileChanged

param {
  [string]$username
}

Write-Host $username

$dir = "C:\Users\IEUser\Saved Games\Frontier Developments\Elite Dangerous"
$filter = "*.log"
$global:FileChanged = $false
$global:fileLengthLast = 0

$temp = "$env:temp\ed-websocket.tmp"

if (Test-Path $temp) {
  Remove-Item $temp
}
# $tempFile = [io.path]::GetTempFileName()

$Watcher = New-Object IO.FileSystemWatcher $dir, $filter -Property @{
  IncludeSubdirectories = $false;
  NotifyFilter = [System.IO.NotifyFilters]'FileName,LastWrite'
}

#Write-Host $dir



Register-ObjectEvent $Watcher Changed -SourceIdentifier FileChanged -Action {
 $latestLog = $Event.SourceEventArgs.Name
 $global:fullPath = "$dir\$latestLog"
# Write-Host $global:fullPath
 $lines = Get-Content $global:fullPath | Measure-Object -Line
 if ($lines.Lines -ne $global:fileLengthLast) {
   $global:fileLengthChange = $lines.Lines - $global:fileLengthLast
#   Write-Host "changed lines: $global:fileLengthChange"
   $global:fileLengthLast = $lines.Lines
#   Write-Host "changed fileLengthLast: $global:fileLengthLast"
   $global:FileChanged = $true
  }
  # } | Add-Content $temp
}


while ($true) {

    while ($global:FileChanged -eq $true){
      $global:FileChanged = $false
      Get-Content $global:fullPath | Select-Object -Last $global:fileLengthChange
      Write-Host "fileLengthChange: $global:fileLengthChange"
      #Write-Host "debug"
    }

}
