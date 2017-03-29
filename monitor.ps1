Unregister-Event -SourceIdentifier FileChanged

#Write-Host "monitor.ps1"
# test git 2

$dir = "C:\Users\IEUser\Saved Games\Frontier Developments\Elite Dangerous"
#$dir = "F:\" #debug
#$dir = "\\vboxsrv\journals"
$filter = "*.log"

$MutexName = "Global\ReadFile"
$MutexWasCreated = $false;
try {
    $Mutex = [System.Threading.Mutex]::OpenExisting($MutexName);
} catch {
    $Mutex = New-Object System.Threading.Mutex($false,$MutexName,[ref]$MutexWasCreated);
}

$watcher = New-Object System.IO.FileSystemWatcher -Property @{Path = $dir;
                                                              Filter = $filter;
                                                              NotifyFilter = [System.IO.NotifyFilters]'FileName,LastWrite'}


Register-ObjectEvent -InputObject $watcher -EventName Changed -SourceIdentifier FileCreated #-Action $CreatedActions

while ($true){  
    $events = @(Get-Event -SourceIdentifier FileCreated -ErrorAction SilentlyContinue )
    foreach($event in $events) {
        $Mutex.WaitOne() | Out-Null
        try {
            Get-Content $event.sourceEventArgs.FullPath -ReadCount 0 | Write-Host
        } catch {
            Write-Host $_
        }
        $Mutex.ReleaseMutex() | Out-Null

        Remove-Event -EventIdentifier $event.EventIdentifier
    }
    $null = Wait-Event -SourceIdentifier FileCreated
}