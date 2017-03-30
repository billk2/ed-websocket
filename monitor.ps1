param([string]$username = "test")

Unregister-Event -SourceIdentifier FileChanged

$dir = "C:\Users\$username\Saved Games\Frontier Developments\Elite Dangerous"
$filter = "*.log"
$global:FileChanged = $false
$global:fileLengthLast = 0

$Watcher = New-Object IO.FileSystemWatcher $dir, $filter -Property @{
  IncludeSubdirectories = $false;
  NotifyFilter = [IO.NotifyFilters]'FileName,LastWrite'
  EnableRaisingEvents = $true  
}

Register-ObjectEvent $Watcher Changed -SourceIdentifier FileChanged -Action {

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


while ($true) {

  while ($global:FileChanged -eq $true){
    $global:FileChanged = $false
    Get-Content $global:fullPath -Tail $global:fileLengthChange
  }
}
