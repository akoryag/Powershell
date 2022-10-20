$Date = (Get-Date).ToString('dd.MM.yyyy')
$OU = 'OU Path'
$fileAdm = 'ADMpassword_'+$date+'.txt' 
$fileBit = 'Bitlocker_'+$Date+'.txt' 
$ADcomputers = Get-ADComputer -Filter * -SearchBase $OU 

$result = foreach ($ADcomputer in $ADcomputers)
{
Get-ADObject -Filter {objectClass -eq 'msFVE-RecoveryInformation'} -SearchBase $ADcomputer.DistinguishedName -Properties msFVE-RecoveryPassword |
    Select-Object @{l='ComputerName';e={$ADcomputer.Name}}, @{l='Key ID';e={($_.Name ).Split('{')[1].TrimEnd('}')}}, @{l='RecoveryPassword';e={$_.'msFVE-RecoveryPassword'}}
}
$result | Out-File $fileBit
$ADcomputers | Get-AdmPwdPassword -ComputerName {$_.Name} | Select-Object ComputerName, Password, ExpirationTimestamp | Out-File $fileAdm

Send-MailMessage `
-From From@example.com `
-Subject 'ADMpassword and Bitlocker' `
-To To@example.com `
-Body 'Выгрузка пароля Bitlocker и пароля локального администратора - завершена' `
-SmtpServer smtp.mail.ru `
-Attachments $fileAdm, $fileBit `
-Encoding 'UTF8'