$path_hosts="C:\Windows\System32\drivers\etc\hosts"
$regrex_ip4 = "\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b";

$array_vm_names=@(get-vm `
                 | Select -ExpandProperty Networkadapters `
                 | Select -ExpandProperty VMName);

$array_ip_addreses =@((get-vm `
                     | Select -ExpandProperty Networkadapters `
                     | Select -ExpandProperty IPAddresses `
                     | Select-String -Pattern $regrex_ip4) `
                     | Out-String);

$array_vms_data=New-Object System.Collections.ArrayList

for($i=0; $i -le $array_vm_names.Length; $i++) {
    if ($array_ip_addreses[$i]) {
        $array_vms_data+=(($array_ip_addreses[$i] + " " + $array_vm_names[$i]) -replace "`n|`r");
    }
}

[string[]]$vms_hosts = Get-Content -Path $path_hosts

foreach ($i in $array_vms_data) {
    
    $a_ip, $a_name = $i.split()

    $b_ip, $b_name;

    foreach ($j in $vms_hosts) {
        $b_ip, $b_name = $j.split()

        #change record
        if ($a_ip -notmatch $b_ip -and $a_name -match $b_name) {
            #delete
            Set-Content -Path $path_hosts -Value (get-content -Path $path_hosts | Select-String -Pattern $a_name -NotMatch)
            #apend new one
            $i | Out-File -FilePath $path_hosts -append -Encoding UTF8
        }

    }

    #add new record
    if (!$b_name) {
        $i | Out-File -FilePath $path_hosts -append -Encoding UTF8
    }
}
