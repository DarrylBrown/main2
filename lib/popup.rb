=begin rdoc
*Module_Name*
  Popup

*Description*
  Test script popup methods

*Variables*
    

=end

module  Popup
  #TODO include Setup module in order to pass the systemos class variables.
  # there should be a more appropriate way to do this
  include Setup


  #    - thread based method to login to web page
  #    - acknowledge security alert
  #    - uses standard .click as opposed to .click_no_wait
  def login(site,user,pswd)

    conn_to = @@titl + site
    Thread.new{
      thread_cnt = Thread.list.size
      sleep 1 #This sleep is critical, timing may need to be adjusted
      Watir.autoit.WinWait(conn_to)
      Watir.autoit.WinActivate(conn_to)
      Watir.autoit.Send(user)
      Watir.autoit.Send('{TAB}')
      Watir.autoit.Send(pswd)
      popup('Windows Internet Explorer',@@ok) #launch thread for alert popup
      Watir.autoit.Send('{ENTER}')
    }
  end


  #
  #   - thread based method to acknowledge security alert
  def popup(name,btn) #alert popup thread
    Thread.new{
      sleep 1 # This sleep is critical, timing may need to be adjusted
      Watir.autoit.WinWait(name)
      Watir.autoit.ControlClick(name,"",btn)
    }
  end

  
  #
  #  - Handle popup and return pop up text if 'rtxt' is true
  #  - user_input is used for firmware update file dialogue box
  def jsClick(button)
    if button=="OK"||button=="ȷ��"
      button=@@ok
    else
      button =@@cancel
    end
    wait = 20
    hwnd1 = $ie.enabled_popup(wait) # wait up to 20 seconds for a popup to appear
    if (hwnd1)
      w = WinClicker.new
      popup_text = w.getStaticText_hWnd(hwnd1).to_s.delete "\n"
      sleep (0.1)
      w.clickWindowsButton_hwnd(hwnd1, "#{button}")
      w = nil
    end
    return popup_text
  end


  #
  #  - after attempting to save an invalid character - reset OK or
  #  - reset Cancel And reset OK, return text in popup
  def invChar(pop_exp)
    save.click_no_wait
    poptxt = jsClick(@@ok)
    if (pop_exp == "can")
      reset.click_no_wait
      jsClick(@@cancel)
      edit.click
    end
    reset.click_no_wait
    jsClick(@@ok)
    return poptxt
  end


  #
  #  - reset Cancel or reset OK, implicitly return text in popup
  #  - res = Reset
  #  - can = Cancel
  def res_can(pop_exp)
    if (pop_exp == "res")
      reset.click_no_wait
      jsClick(@@ok)
    elsif (pop_exp == "can")
      reset.click_no_wait
      jsClick(@@cancel)
    end
  end


  #
  #  - reset to factory defaults ok or cancel, return text in popup
  def res_factory(pop_exp)
    if (pop_exp == "res")
      restart1.click_no_wait
      jsClick(@@ok)
    elsif (pop_exp == "can")
      restart1.click_no_wait
      jsClick(@@cancel)
    end
  end


end
