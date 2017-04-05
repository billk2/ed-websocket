param([string]$dir = "C:\Users\bill\Saved Games\Frontier Developments\Elite Dangerous")

Unregister-Event -SourceIdentifier FileChanged

$filter = "Journal.*.log"
$global:FileChanged = $false
$global:fileLengthLast = 0

$Watcher = New-Object IO.FileSystemWatcher
$Watcher.path = $dir
$Watcher.filter = $filter
$Watcher.IncludeSubdirectories = $false
$Watcher.EnableRaisingEvents = $true
# $Watcher.NotifyFilter = [System.IO.NotifyFilters]'Size, FileName, LastWrite'

$action = {
 $latestLog = $Event.SourceEventArgs.Name
 $global:fullPath = "$dir\$latestLog"
 $lines = Get-Content $global:fullPath | Measure-Object -Line

 if ($lines.Lines -ne $global:fileLengthLast) {

   if ($lines.Lines -lt $global:fileLengthLast) {
     $global:fileLengthLast = 0
   }

   $global:fileLengthChange = $lines.Lines - $global:fileLengthLast
   $global:fileLengthLast = $lines.Lines
   $global:FileChanged = $true
  }
}

Register-ObjectEvent $Watcher "Changed" -SourceIdentifier FileChanged -Action $action

while ($true) {

  while ($global:FileChanged -eq $true){
    $global:FileChanged = $false
    # Get-Content $global:fullPath -Tail $global:fileLengthChange
    Get-Content $global:fullPath -Wait
  }
}
