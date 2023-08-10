Start-Transcript -Path "\\***FILE SHARE***\OffboardingUser.txt" -Force -noClobber -Append

$user = Read-Host -Prompt 'What is the SAM account name of the user (First Initial, Last Name)'
$domainfinder = Get-ADUser -Server '***DOMAIN1***' $user -Properties *

#If there are multiple domains, this can help distinguish which one the current user is in. 
#uses locally stored detection of command errors to know what domain the user is in
if($?){
    $domain = '***DOMAIN1.com'
    Write-Host '***DOMAIN1 User'
}
else{
    $domain = '***DOMAIN2.com'
    Write-host '***DOMAIN2 User'
}


$userwithADproperties = Get-ADUser -Server $domain $user -Properties *
$fullname = $userwithADproperties.name
$date = get-date -format d
$d1archive = '\\***FILE SHARE***\User_Archive\'
$d2archive = '\\***FILE SHARE***\User_Archive\DOMAIN2\'

#Decides where to create user archive folder based on domain
if($domain -eq '***DOMAIN2.com'){
    $archivePath = $d2archive+$fullname
}
else{
     $archivePath = $d1archive+$fullname
}

#Creates archive dir, archives AD properties, removes groups, resets password, clears proxyaddress attribute, 
#clears manager and telephone fields, updates description with term date, and disables account
New-Item -ItemType directory -Path $archivePath
$userwithADproperties | Out-File -FilePath "$archivePath\Userarchive"
net user $user /domain | Out-File -FilePath "$archivepath\Netuser"
$userwithADproperties.MemberOf | Remove-ADGroupMember -Server $domain -Members $user -PassThru
Set-ADAccountPassword -Server $domain -Identity $user -Reset -NewPassword (ConvertTo-SecureString -AsPlainText '9fyNZ_ua3WSri2Qw+8cV' -Force) 
Set-ADUser -Server $domain $user -Clear manager
Set-ADUser -Server $domain $user -Clear telePhoneNumber
Set-ADUser -Server $domain $user -Description "TERM $date"
Set-ADUser -Server $domain $user -EmployeeID "TERM $date"
Disable-ADAccount -Server $domain $user

Stop-Transcript
