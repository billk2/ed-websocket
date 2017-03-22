Unregister-Event -SourceIdentifier FileCreated
Unregister-Event -SourceIdentifier FileChanged


$dir = "C:\Users\bill\Saved Games\Frontier Developments\Elite Dangerous"
$filter = "*.log"
$global:FileCreated = $false

$Watcher = New-Object IO.FileSystemWatcher $dir, $filter -Property @{
  IncludeSubdirectories = $false;
  NotifyFilter = [System.IO.NotifyFilters]'FileName,LastWrite'
}


Register-ObjectEvent $Watcher Created -SourceIdentifier FileCreated -Action {
 $global:FileCreated = $true
 $global:FileChanged = $true
 $latestLog = $Event.SourceEventArgs.Name
 $global:fullPath = "$dir\$latestLog"
 Get-Content $global:fullPath
 $lines = Get-Content $global:fullPath | Measure-Object -Line
 $global:fileLengthLast = $lines.Lines
}


while ($global:FileCreated -ne $true){
  sleep -Sec 5
}


Register-ObjectEvent $Watcher Changed -SourceIdentifier FileChanged -Action {
 $lines = Get-Content $global:fullPath | Measure-Object -Line
 if ($lines.Lines -ne $global:fileLengthLast) {
   $global:fileLengthChange = $lines.Lines - $global:fileLengthLast
   $global:fileLengthLast = $lines.Lines
   $global:FileChanged = $true
 }
}


while ($true) {
  while ($global:FileChanged -eq $true){
    $global:FileChanged = $false
    Get-Content $global:fullPath | Select-Object -Last $global:fileLengthChange
  }
}
