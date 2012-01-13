=begin rdoc
*Revisions*
  | Change                                               | Name        | Date  |

*Test_Script_Name*
  netwrk_settg

*Test_Case_Number*
  700.050.20.110

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
  #Click the Configure Network Settings link on the left side of window
  #Login if not called from controller
  g.logn_chk(g.netset,excel[1])
  
  row = 1
  while(row <= rows)
    puts "Test step #{row}"
    row +=1 # add 1 to row as execution starts at drvr_ss row 2
    sleep 5
    g.edit.click

    # Write Network Settings  fields
    speed = ((ws.Range("k#{row}")['Value']).to_i).to_s
    puts "#{speed}"
    g.net_speed.select_value(speed)
    
    mode = ((ws.Range("l#{row}")['Value']).to_i).to_s
    puts "#{mode}"
    g.net_boot6mode(mode).set
    
    if (g.net_boot6mode(0).checked? == true)
      g.net_ip6addr.set(ws.Range("m#{row}")['Value'].to_s)
      g.net_preflen.set(ws.Range("n#{row}")['Value'].to_s)
      g.net_ipv6gateway.set(ws.Range("o#{row}")['Value'].to_s)
    end
    
    #Is there a popup expected? 
    pop = ws.Range("af#{row}")['Value'].to_s 
    puts "  pop_up value = #{pop}" unless pop == 'no'
    #sleep 1

    #If popup, handle with reset OK or reset Cancel to continue
    if (pop == "res")
      popup_txt  = g.invChar(pop)
      puts "Pop-Up text is #{popup_txt}"
      ws.Range("bk#{row}")['Value'] = popup_txt
    end
 
    if (pop == "can")
      ws.Range("bk#{row}")['Value'] = g.res_can(pop)
      g.save.click_no_wait
      g.jsClick('OK')
    end

    #If reset Cancel, do not save
    if (pop == "no")
      g.save.click_no_wait
      g.jsClick('OK')
    end
 
    #read Network Settings  field values
    sleep 1
    g.edit.click
    
    ws.Range("bc#{row}")['Value'] = g.net_speed.value
    
    
    if (g.net_boot6mode(0).checked? == true)
     ws.Range("bd#{row}")['Value'] = "0"
     ws.Range("be#{row}")['Value'] = g.net_ip6addr.value
     ws.Range("bf#{row}")['Value'] = g.net_preflen.value
     ws.Range("bg#{row}")['Value'] = g.net_ipv6gateway.value
    elsif (g.net_boot6mode(1).checked? == true)
     ws.Range("bd#{row}")['Value'] = "1"
    else
     ws.Range("bd#{row}")['Value'] = "2"
    end  
  
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