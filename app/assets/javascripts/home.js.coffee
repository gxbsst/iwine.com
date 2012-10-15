jQuery ->
  if $('#container .pagination').length
    $(window).scroll ->
      url = $('#home .pagination .next a').attr('href')     
      if url && $(window).scrollTop() > $(document).height() - $(window).height() - 50
        $('.pagination').text("获取更多...")
        $("#waterfall_loading").show()
        $.getScript(url).done ->
        	$("#waterfall_loading").hide()
        	
    $(window).scroll()
    
