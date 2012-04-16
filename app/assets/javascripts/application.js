// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//

//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require underscore
//= require backbone
// require backbone-localstorage
//= require fancybox
//= require jcrop
//= require wines
//= require rails.validations
//= require swfobject
//= require jquery.uploadify.v2.1.4
//= require best_in_place
//= require stickies
//= require settings
//= require kissy

$(document).ready(function(){
<<<<<<< HEAD
=======

    // 下拉菜单

    $('a.arrow_down').click(function (event) {
        // $(this).preventDefault();
        event.preventDefault();
        $('ul.drop_down_menu').slideToggle('medium');
    });

    // 酒详细页面
    $("a.wine_profile").fancybox();

>>>>>>> 7e1b74b49a7052a4c5ebd644dca00a1fed53e1c8
    // 添加朋友、酒等
    $("a.add_green").fancybox({
        maxWidth        : 500,
        maxHeight       : 150,
        fitToView       : false,
        width           : '70%',
        height          : '70%',
        autoSize        : false,
        closeClick      : false,
        openEffect      : 'none',
<<<<<<< HEAD
        closeEffect     : 'none',
        helpers : {
            overlay : {
                opacity : 0.8,
                css : {
                    'background-color' : '#FFF'
                }
            }

        } // end helper

    });
=======
        closeEffect     : 'none'
    });


>>>>>>> 7e1b74b49a7052a4c5ebd644dca00a1fed53e1c8

});




