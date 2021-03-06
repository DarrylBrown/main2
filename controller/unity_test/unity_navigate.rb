# To change this template, choose Tools | Templates
# and open the template in the editor.

class Unity_Navigate

 
  #  - Tab area frameset abstration
  def tab
    frame_text = self.redirect {$ie.show_frames}
    if frame_text =~ /tabArea/ then $ie.frame(:name, 'tabArea')
    else $ie
    end
  end

 
  def unity_config(unity_tab)
    tab.element(:id, unity_tab)
  end

  # - Navigation link frameset abstration
  def nav
    frame_text = self.redirect {$ie.show_frames}
    if frame_text =~ /mainFrameSet/ then $ie.frame(:id, 'main').frame(:id, 'navigationFrame')
    else $ie.frame(:id, 'navigationFrame')
    end
  end

  # - Navigate to a special page
  def navigate_node(navigate_node)
      nav.link(:text,navigate_node)
  end
  
  def wait()
    #test the interval for $ie.wait 
    #puts DateTime.now.sec
    #$ie.wait
    sleep(0.5)
    #puts DateTime.now.sec
  end

  #  - returns true or false if the web page under test has a frame named
  def has_frame?(frame_name)
    frame_text = self.redirect {$ie.show_frames}
    !frame_text.match("#{frame_name}").nil?
  end

  #   - buttons
  #   - check boxes
  #   - combo boxes
  #   - text fields
  def det
    if has_frame?('main') then  $ie.frame(:id, 'main').frame(:id, 'rframeset').frame(:id, 'detailArea')
    else $ie.frame(:id, 'detailArea')
    end
  end

  # button

  def click(button_name)
      #$ie.frame(:id, 'detailArea').button(:id, 'editButton')
      det.button(:id, button_name)
      #$ie.frame(:index, 5).button(:id, 'editButton')
  end

  # file filed
  def set_filefield( field_name)
    $ie.file_field(:id, field_name)
  end

  # text field
  def set_text_value(field_id)
      det.text_field(:id, field_id)
  end
  
  # combo box
  def select_combo(select_name)
      det.select_list(:id, select_name)
  end

  # check box
  def set_check_value(checkbox_id)
    det.checkbox(:id, checkbox_id)
  end

    #This method is used to redirect stdout to a string
  def redirect
    orig_defout = $defout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = orig_defout
  end

  

end

