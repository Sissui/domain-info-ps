#####################################################################################################
#                                                                                                   #
#                                    CREATED BY SISSUI IN 17.10.2021                                #
#                                         LAST CHANGE 08.04.2022                                    #
#                                                                                                   #
#                               THIS IS SIMPLE USER MANAGER FOR 1ST LINE OF HELP                    #  
#                                        WORKING ON WINDOWS DOMAIN                                  #
#                                                                                                   #
#####################################################################################################


#pull user data or change address email
function Get-user-info{
    $number = Read-Host -Prompt "`n`tprovide user identificator"
    try{
        if(Get-ADUser -Identity $number){
            
            Write-Host "`n`t`t1. Email change" -ForegroundColor Cyan
            Write-Host "`t`t2. Display user info" -ForegroundColor Cyan
        
            $opcja = Read-Host -Prompt "`n`t`t`tChoose what do you want me to do?"
            
            #mail change
            if($opcja -eq 1){
                
                
                Get-ADUser $number -Properties * | Format-List DisplayName,Modified,EmailAddress,otherMailbox,PasswordLastSet
                
                $new_alternate_email = Read-Host -Prompt "`n`t`t`t`tProvide new alternate email"
                Set-ADUser –Id $number -Clear "othermailbox"
                Set-ADUser -id $number -Add @{ othermailbox = "$new_alternate_email"}
                Get-ADUser $number -Properties * | Format-List DisplayName,otherMailbox,CN
                
            #Display user info
            }elseif($opcja -eq 2){

                Write-Host "`n`t`t`t2. Info about user with ID: $number" -ForegroundColor Cyan
                
                Get-ADUser $number -Properties * | Format-List DisplayName,logonCount,Modified,CN,EmailAddress,LastBadPasswordAttempt,PasswordLastSet,otherMailbox,proxyAddresses
                
               
            }

         }

    }catch{
        Write-Host "`n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!THERE IS NO USER WITH THIS ID IN THIS DOMAIN!!!!!!!!!!!!!!!!!!!!!!!!!!!!`n" -ForegroundColor Red
    }
    
}

#display computer info
function Get-ip{
    try{
        
        Write-Host "`n`t`t1. Find with user ID" -ForegroundColor Cyan
        Write-Host "`t`t2. Find with computer name" -ForegroundColor Cyan
        Write-Host "`t`t3. Find with IP Address" -ForegroundColor Cyan

        $number = Read-Host -Prompt "`n`t What do you want to search for the computer with?"

        if($number -eq 1){

            $user_id= Read-Host -Prompt "`n`t Provide user ID"
            Get-ADComputer -LDAPFilter "(custom-LastLoggedUser=*$user_id*)" -Properties * | select @{Label="Computername";Ex={$_.name}}, OperatingSystem, @{Label="ServiceTag";Ex={$_.'custom-ServiceTag'.substring(-$_.'custom-ServiceTag'.indexof(" "))}}, @{Label="IPv4";Ex={[ipaddress] $_.'custom-IPv4'}}, ` 
@{Label="MacAddress";Ex={$_.'custom-MacAddress'}}, @{Label="LastLoggedUser";Ex={$_.'custom-LastLoggedUser'}} , @{Label="Surname";Expression={(Get-ADUser -Identity $_.'custom-LastLoggedUser'.Substring(5,7)).surname }}, `
@{Label="GivenName";Expression={(Get-ADUser -Identity $_.'custom-LastLoggedUser'.Substring(5,7)).givenname }}, @{Label="LastLoggedUserDate";Ex={[datetime] $_.'custom-LastLoggedUserDate'}}, `
@{Label="Online";Ex={[bool](Test-Connection -Count 1 -Quiet $_.'custom-ipv4')}} | sort surname | FT -Property * -AutoSize -Wrap 
            


        }elseif($number -eq 2){
        
            $computer_name = Read-Host -Prompt "`n`t Provide computer name"
            Get-ADComputer -LDAPFilter "(Name=*$computer_name*)" -Properties * | select @{Label="Computername";Ex={$_.name}}, OperatingSystem, @{Label="ServiceTag";Ex={$_.'custom-ServiceTag'.substring(-$_.'custom-ServiceTag'.indexof(" "))}}, @{Label="IPv4";Ex={[ipaddress] $_.'custom-IPv4'}}, ` 
@{Label="MacAddress";Ex={$_.'custom-MacAddress'}}, @{Label="LastLoggedUser";Ex={$_.'custom-LastLoggedUser'}} , @{Label="Surname";Expression={(Get-ADUser -Identity $_.'custom-LastLoggedUser'.Substring(5,7)).surname }}, `
@{Label="GivenName";Expression={(Get-ADUser -Identity $_.'custom-LastLoggedUser'.Substring(5,7)).givenname }}, @{Label="LastLoggedUserDate";Ex={[datetime] $_.'custom-LastLoggedUserDate'}}, `
@{Label="Online";Ex={[bool](Test-Connection -Count 1 -Quiet $_.'custom-ipv4')}} | sort surname | FT -Property * -AutoSize -Wrap
        
        }elseif($number -eq 3){
        
            $address_ip = Read-Host -Prompt "`n`t Provide IP Adress"
            Get-ADComputer -LDAPFilter "(customCI-IPv4=$adress_ip)" -Properties * | select @{Label="Computername";Ex={$_.name}}, OperatingSystem, @{Label="ServiceTag";Ex={$_.'custom-ServiceTag'.substring(-$_.'custom-ServiceTag'.indexof(" "))}}, @{Label="IPv4";Ex={[ipaddress] $_.'custom-IPv4'}}, ` 
@{Label="MacAddress";Ex={$_.'custom-MacAddress'}}, @{Label="LastLoggedUser";Ex={$_.'custom-LastLoggedUser'}} , @{Label="Surname";Expression={(Get-ADUser -Identity $_.'custom-LastLoggedUser'.Substring(5,7)).surname }}, `
@{Label="GivenName";Expression={(Get-ADUser -Identity $_.'custom-LastLoggedUser'.Substring(5,7)).givenname }}, @{Label="LastLoggedUserDate";Ex={[datetime] $_.'custom-LastLoggedUserDate'}}, `
@{Label="Online";Ex={[bool](Test-Connection -Count 1 -Quiet $_.'custom-ipv4')}} | sort surname | FT -Property * -AutoSize -Wrap
        }

    }catch{
        Write-Host "`n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!THERE IS NO USER WITH THIS ID IN THIS DOMAIN!!!!!!!!!!!!!!!!!!!!!!!!!!!!`n" -ForegroundColor Red
    }
}
#find user with his alternative email address
function Get-user-info-via-othermailbox{
    
        try{
        
        $othermailbox = Read-Host -Prompt "`n`tProvide alternate email address" 
       
        Get-ADuser -filter {othermailbox -like $othermailbox} -Properties * | FT Name, Othermailbox, SamAccountName
        
        }catch{
        Write-Host "`n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!THERE IS NO USER WITH THIS ID IN THIS DOMAIN!!!!!!!!!!!!!!!!!!!!!!!!!!!!`n" -ForegroundColor Red
    }
}
#Show all accounts that match name and surname
function Get-account-via-alias{
        
        try{
        
        $nameAndSurname = Read-Host -Prompt "`n`tProvide name and surrname"
         
            Get-ADuser -filter {DisplayName -like $nameAndSurname} -Properties * | FT Name, CN, proxyAddresses

        }catch{                  
            Write-Host "`n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!THERE IS NO USER WITH THIS ID IN THIS DOMAIN!!!!!!!!!!!!!!!!!!!!!!!!!!!!`n"  -ForegroundColor Red
        }
}
#Quick search if user have VPN groups and allow you to add it without using dsa
function Get-VPN-Groups{
    
    try{
        $number=Read-Host -Prompt "`n`tProvide user ID"
        Get-ADPrincipalGroupMembership -Identity $number | Where-Object { $_.name -like "*VPN*"} | FT name
        if(!(Get-ADPrincipalGroupMembership -Identity $number | Where-Object { $_.name -like "*VPN*"})){
            
            Write-Host "`n`t`There is no VPN groups on this user." -ForegroundColor Red

        }

            
            #some options to do if user don't have any groups
            
            do{
                $option = Read-Host -Prompt "`n`t`t`t1. Add groups`n`t`t`t2. exit.`n`t`t`tChoose one"
                if($option -eq 1){
                
                    $option2 = Read-Host -Prompt "`n`t`t`t`t1. Main policy `n`t`t`t`t2. Main2 policy `n`t`t`t`t3. Main3 policy `n`t`t`t`t4. Cancel`n`t`t`t`tChoose"
                    
                    if($option2 -eq 1){

                        if(Get-ADPrincipalGroupMembership -Identity $number | Where-Object { $_.name -like "VPN-polisa-domyslna"}){
                            Write-Host "`n`t`t`t`t`tThis group is already added, no sense of adding this again." -ForegroundColor Red
                        }else{
                            Add-ADGroupMember -Identity VPN-polisa-domyslna -Members $number
                            Write-Host "`n`t`t`t`t`tProperly added 'Main2 policy'" -ForegroundColor Green
                        }
                    
                    }elseif($option2 -eq 2){

                        if(Get-ADPrincipalGroupMembership -Identity $number | Where-Object { $_.name -like "VPN-HMS"}){
                            Write-Host "`n`t`t`t`t`tThis group is already added, no sense of adding this again" -ForegroundColor Red
                        }else{
                            Add-ADGroupMember -Identity VPN-HMS -Members $number
                            Write-Host "`n`t`t`t`t`tThis group is already 'Main3-policy'"  -ForegroundColor Green
                        }

                    }elseif($option2 -eq 3){

                            if(Get-ADPrincipalGroupMembership -Identity $number | Where-Object { $_.name -like "VPN-ERP"}){
                                Write-Host "`n`t`t`t`t`tThis group is already added, no sense of adding this again" -ForegroundColor Red
                            }else{
                                Add-ADGroupMember -Identity VPN-ERP -Members $number
                                Write-Host "`n`t`t`t`t`tProperly added 'VPN-ERP'" -ForegroundColor Green
                            }

                    }elseif($option2 -eq 4){
                            
                            Write-Host "`n`t`t`t`t`t Exiting from adding vpn groups"  -ForegroundColor Red
                    
                    }
                    
                    
                }elseif($option -eq 2){
                    Write-Host "`n`t`t`t`t`tExit" -ForegroundColor Red
                    $option2 = 4
                }
            }while($option2 -ne 4)
        
    }catch{
        Write-Host "`n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!THERE IS NO USER WITH THIS ID IN THIS DOMAIN!!!!!!!!!!!!!!!!!!!!!!!!!!!!`n" -ForegroundColor Red
    }
}

#menu
do{
    Write-Host "`n1. Find computer info" -ForegroundColor Cyan
    Write-Host "2. Find user info" -ForegroundColor Cyan
    Write-Host "3. Find user info with alternate emailaddress" -ForegroundColor Cyan
    Write-Host "4. Find user info with name and surname" -ForegroundColor Cyan
    Write-Host "5. Find if user have VPN groups" -ForegroundColor Cyan
    Write-Host "6. Exit`n" -ForegroundColor Red

    $option = Read-Host -Prompt "`tWhat do you want to do?"
    
    if($option -eq 1){
        Get-ip
    }elseif($option -eq 2){
        Get-user-info
    }elseif($option -eq 3){
        Get-user-info-via-othermailbox
    }elseif($option -eq 4){
        Get-account-via-alias
    }elseif($option -eq 5){
        Get-VPN-Groups
    }elseif($option -eq 6){
        Write-Host "Thank you for using our script. Formating C drive in 5... 4... 3... 2..."        
    }
}while($opcja -ne 6)