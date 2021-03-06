=begin rdoc
*Revisions*
  | Change                                               | Name        | Date  |

*Test_Script_Name*
  cfg_dns_info3

*Test_Case_Number*
  700.60.20.110

*Description*
  Validate the Network Settings Configuration
     - Positive
     - Negative
    
*Variable_Definitions*
    s = test start time
    f = test finish time
    e = test elapsed time
    roe = row number in controller spreadsheet
    excel = nested array that contains an instance of excel and driver parameters
    ss = spreadsheet
    wb = workbook
    ws = worksheet
    dvr_ss = driver spreadsheet
    rows = number of rows in spreadsheet to execute
    site = url/ip address of card being tested
    name = user name for login
    pswd = password for login

=end

#Launch the Configure Network Settings ruby script
#Add library file to the path
$:.unshift File.dirname(__FILE__).chomp('driver/web_ipv6')<<'lib' # add library to path
s = Time.now
require 'generic'
require 'watir/process' 

begin 
  puts" \n Executing: #{(__FILE__)}\n\n" # print current filename
  g = Generic.new
  roe = ARGV[1].to_i
  #Open up a new excel instance and save it with the timestamp.
  #Open the IE browser
  #Collect the support page information and save it in the time stamped spreadsheet.
  excel = g.setup(__FILE__)
  wb,ws = excel[0][1,2]
  rows = excel[1][1] 

  $ie.speed = :zippy
  #Navigate to the 'Configure' tab
  g.config.click
  $ie.maximize  
  #Click the Configure  DNS Settings link on the left side of window
  #Login if not called from controller
  g.logn_chk(g.dns,excel[1])
  
  row = 1
  while(row <= rows)
    puts "Test step #{row}"
    row +=1 # add 1 to row as execution starts at drvr_ss row 2
	
    #read DNS Settings  field values
    sleep 1
    g.edit.click
    
    #ws.Range("bc#{row}")['Value'] = g.dns_mode("1")
	
	if (g.dns_mode(1).checked? == true)
     
	 ws.Range("bc#{row}")['Value'] = "1"
	 
	end
	
	ws.Range("bd#{row}")['Value'] = g.dns_addr1.value
    ws.Range("be#{row}")['Value'] = g.dns_addr2.value
    ws.Range("bf#{row}")['Value'] = g.dns_int.value
    ws.Range("bg#{row}")['Value'] = g.dns_suf.value

    g.save.click_no_wait
    g.jsClick('OK')
    wb.Save
  end

  f = Time.now  #finish time
#Capture error if any in the script  
rescue Exception => e
  f = Time.now  #finish time 
  puts" \n\n **********\n\n #{$@ } \n\n #{e} \n\n ***"
  error_present=$@.to_s

ensure #this section is executed even if script goes in error
    # If roe > 0, script is called from controller
    # If roe = 0, script is being ran independently
    #Close and save the spreadsheet and thes web browser.
    g.tear_down_d(excel[0],s,f,roe,error_present)
    if roe == 0
      $ie.close
    end
end