$(document).ready(function() {
    /* stickies */
    $('#stickies .stickies_close_area a').click(function() {
        $(this).parent().parent().fadeOut('slow');
        return false;
    })

    function hideStikie(){
    	$('#stickies').fadeOut('slow');
    }
     setTimeout(hideStikie, 5000)
});