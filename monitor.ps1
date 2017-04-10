param([string]$dir = "C:\Users\bill\Saved Games\Frontier Developments\Elite Dangerous")

Unregister-Event -SourceIdentifier FileChanged

$filter = "Journal.*.log"
$global:fileChanged = $false
$global:fileLengthLast = 0

$Watcher = New-Object IO.FileSystemWatcher
$Watcher.path = $dir
$Watcher.filter = $filter
$Watcher.IncludeSubdirectories = $false
$Watcher.EnableRaisingEvents = $true
# $Watcher.NotifyFilter = [System.IO.NotifyFilters]'Size, FileName, LastWrite'
$Watcher.NotifyFilter = [System.IO.NotifyFilters]::Size
Write-Host $dir

$action = {
 $latestLog = $Event.SourceEventArgs.Name
 $global:fullPath = "$dir\$latestLog"
 Write-Host $global:fullPath
 $lines = Get-Content $global:fullPath | Measure-Object -Line

 if ($lines.Lines -ne $global:fileLengthLast) {

   if ($lines.Lines -lt $global:fileLengthLast) {
     $global:fileLengthLast = 0
   }
   Write-Host "Changing"
   $global:fileLengthChange = $lines.Lines - $global:fileLengthLast
   $global:fileLengthLast = $lines.Lines
   $global:fileChanged = $true
  }
}

Register-ObjectEvent $Watcher "Changed" -SourceIdentifier FileChanged -Action $action

while ($true) {

  while ($global:fileChanged -eq $true){
    Write-Host "Changed"
    Write-Host $global:fullPath
    Write-Host "{'warning': ['Logging journal to $global:fullPath']}"
    $global:fileChanged = $false
    # Get-Content $global:fullPath -Tail $global:fileLengthChange
    Get-Content $global:fullPath -Wait
  }
}
