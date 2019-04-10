$result1=@()

$FinalResult = @()
$now = Get-Date	
$date=$now.ToShortDateString()
$info=@()
$accessedservers=@()

$servers = get-content "$psscriptroot\list.txt" -ErrorAction SilentlyContinue

foreach($node in $servers)
{

if(Test-Connection -ComputerName $node -BufferSize 32 -Count 4 -Quiet)
{
 Get-Service wmpnetworksvc -ComputerName $node | ft machinename,name,displayname, status,starttype -AutoSize 
 
$accessedservers += $node

}

else
{

Write-Host "$node Server Not Accessbile : Check network connectivity or, Access Rights" -ForegroundColor Red

}

}

Read-Host "Press enter to restart the Citrix Broker Service"

foreach($node1 in $accessedservers)
{
       

    Start-Service -InputObject $(Get-Service wmpnetworksvc -ComputerName $node1)

    Write-host "successfully restarted broker services on $node1" -ForegroundColor Green

    Get-Service wmpnetworksvc -ComputerName $node1 | ft machinename,name,displayname, status,starttype -AutoSize 

    $machine=$machine + 1
    
    if($machine -eq $accessedservers.count)
    
    {

  break
    
    }

    else {sleep -Seconds 900}
}

Foreach($node2 in $accessedservers)
{

$FinalResult= Get-Service wmpnetworksvc -ComputerName $node2

$result1 += New-Object -TypeName PSObject -Property @{
            
            'machine' = $FinalResult.machinename
            'name'= $FinalResult.Name
            'dname'= $FinalResult.DisplayName
            'status'= $FinalResult.Status
             
            }
            

$Outputreport1 = "<HTML><TITLE> Citrix Broker Service Report </TITLE>
                     <BODY background-color:peachpuff>
                     <font color =""#99000"" face=""Microsoft Tai le"">
                     <H2> Citrix Broker Service Report  </H2></font>
                     <Table border=1 cellpadding=0 cellspacing=1>
					   <TR bgcolor=gray align=center>
                       <TD><B>MachineName</B></TD>
                       <TD><B>ServiceName</B></TD>
                       <TD><B>DisplayName</B></TD>
                       <TD><B>Status</B></TD></TR>"	 


Foreach($entry1 in $result1) 
            { 
          
          $Outputreport1 += "<TD>$($entry1.machine)</TD><TD align=center>$($entry1.name)</TD><TD align=center>$($entry1.dname)</TD><TD align=center>$($entry1.status)</TD></TR>" 
        }
     $Outputreport1 += "</Table></BODY></HTML>" 
        }
#################################################################################################

#           Broker-HyperVisor Section
#################################################################################################


asnp citrix*
$frag1=@()
$brokername=@()
$brokerresult=@()
$result2=@()
$index1=0
$brokername= (Get-BrokerHypervisorConnection -adminaddress dklynctxdc1).name

foreach($name in $brokername)

{

$brokerresult= Get-BrokerHypervisorConnection -adminaddress dklynctxdc1

$result2 += New-Object -TypeName PSObject -Property @{
            
            'Name' = $brokerresult[$index1].name
            'PreferredController'= $brokerresult[$index1].preferredcontroller
            'State'= $brokerresult[$index1].state
            'Uid'= $brokerresult[$index1].Uid
            'ExplicitPreferredController'= $brokerresult[$index1].ExplicitPreferredController
            'HypHypervisorConnectionUid'= $brokerresult[$index1].HypHypervisorConnectionUid
            'MachineCount'= $brokerresult[$index1].MachineCount
            'MaxAbsoluteActiveActions'= $brokerresult[$index1].MaxAbsoluteActiveActions
            'MaxAbsoluteNewActionsPerMinute'= $brokerresult[$index1].MaxAbsoluteNewActionsPerMinute
            'MaxAbsolutePvdPowerActions'= $brokerresult[$index1].MaxAbsolutePvdPowerActions
            'MaxPercentageActiveActions'= $brokerresult[$index1].MaxPercentageActiveActions
            'MaxPvdPowerActionsPercentageOfDesktops'= $brokerresult[$index1].MaxPvdPowerActionsPercentageOfDesktops
                          
            }

$index1=$index1+1

}
 $frag1= $result2 |ConvertTo-Html -As LIST -PreContent ‘<h2>Get-BrokerHypervisorConnection Report</h2>’ | Out-String

 
 $head = @’

<style>

body { background-color:#cbe6d9;

       font-family:arial;

       font-size:10pt; }

td, th { border:2px solid black;

         border-collapse:collapse; }

th { color:white;

     background-color:black; }

table, tr, td, th { padding: 1px; margin: 0px }

table { margin-left:40px; }

</style>

‘@


 $Outputreport2= ConvertTo-HTML -head $head -PostContent $frag1 
     
################################################################################################

$Outputreport = $Outputreport1 + $Outputreport2

$Outputreport | out-file -filepath $PSScriptroot\Report_$date.html 





















