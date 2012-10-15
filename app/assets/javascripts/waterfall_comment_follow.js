$(document).ready(function(){

    $('.item').live('mouseenter', function(){
        $(".action", this).show();
    });

    $('.item').live('mouseleave', function(){
        $(".action", this).hide();
    });

    $('a.hc').live('click', function(){
        //获得当前窗口高度
        var e = document.getElementById('xxx');
        var offset = {x:0,y:0};
        while (e)
        {
            offset.x += e.offsetLeft;
            offset.y += e.offsetTop;
            e = e.offsetParent;
        }

        if (document.documentElement && (document.documentElement.scrollTop || document.documentElement.scrollLeft))
        {
            offset.x -= document.documentElement.scrollLeft;
            offset.y -= document.documentElement.scrollTop;
        }
        else if (document.body && (document.body.scrollTop || document.body.scrollLeft))
        {
            offset.x -= document.body.scrollLeft;
            offset.y -= document.body.scrollTop;
        }
        else if (window.pageXOffset || window.pageYOffset)
        {
            offset.x -= window.pageXOffset;
            offset.y -= window.pageYOffset;
        }
        var iw_comment = $(this).parents('.item').children('.iw_comment')
        iw_comment.toggle();
        $('#container').masonry('reload');
        if (($(window).height() - offset.y) < iw_comment.offset().top + iw_comment.height()){
            $('html, body').animate({scrollTop: iw_comment.offset().top - $(window).height()/2.0}, 500);
        }
        $('form input.comment_body', iw_comment).focus();
    });

    $(".submit_a").live('click', function(){
        $(this).parents('form').submit();
        return false;
    })
});