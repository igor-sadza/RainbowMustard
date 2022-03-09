$process_name = "$args"
$process_run_directory_pf86 = dir -Path "C:\Program Files (x86)\" -Filter $process_name -Recurse | %{$_.FullName} -PassThru -Wait

$process_run_directory_pf = dir -Path "C:\Program Files\" -Filter $process_name -Recurse | %{$_.FullName} -PassThru -Wait

echo $process_run_directory_pf86
echo $process_run_directory_pf

$session_id = (Get-Process -PID $pid).SessionID
#echo $process_name.ToLower() 

$is_process_running_in_current_session = (query process /server:$SERVER | findstr -I $process_name.ToLower() | findstr -I $session_id)

if ( !($is_process_running_in_current_session) ) {
    if ( !($process_run_directory_pf) ) {
        $process = start-process "$process_run_directory_pf86" -PassThru -Wait
    } 
    else {
        $process = start-process "$process_run_directory_pf" -PassThru -Wait
    }
}

#if ($process.ExitCode) {
logoff
#}

#Write-Host -NoNewLine 'Press any key to continue...';
#$null = $Host.UI.RawUI.ReadKey('NoEcho, includeKeyDown');
