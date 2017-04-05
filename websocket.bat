SET screenshots="%HOMEDRIVE%%HOMEPATH%\Pictures\Frontier Developments\Elite Dangerous"
SET journals="%HOMEDRIVE%%HOMEPATH%\Saved Games\Frontier Developments\Elite Dangerous"
websocketd.exe -port=3306 --staticdir=%screenshots% powershell -ExecutionPolicy ByPass -nologo -sta -noprofile -file monitor.ps1 -dir %journals%
