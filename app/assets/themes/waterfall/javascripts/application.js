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
//= require fancybox
//= require jcrop
//= require waterfall/javascripts/wines
//= require rails.validations
//= require waterfall/javascripts/swfobject
//= require jquery.uploadify.v2.1.4
//= require best_in_place
//= require stickies
//= require waterfall/javascripts/settings
//= require jquery-tools/tabs/tabs
//= require jquery-tools/tabs/tabs.slideshow
//= require waterfall/javascripts/waterfall
//= require waterfall/javascripts/home


$(document).ready(function(){

    // 下拉菜单
    $('a.arrow_down').mouseover(function (event) {
        // $(this).preventDefault();
        event.preventDefault();
        $('ul.drop_down_menu').slideToggle('medium');
    });

    $('ul.drop_down_menu').mouseleave(function (event) {
        $(this).slideToggle('medium');
    });

    $('.globel_navi li.arrow').bind('mouseover mouseout', function(e) {
        if(e.type == 'mouseover') {
            $(this).parents().find('.CategoryDropdown').hide();
            $(this).find('.CategoryDropdown').show();
        }
        else
        {
            // $(this).find('.CategoryDropdown').hide();
        } 
      
    });

    // Wine 下拉菜单 
    // $(".globel_navi li.arrow").mouseover(function(event){
    //     $(this).find('.CategoryDropdown').slideToggle('medium');
    // });
    $('.CategoryDropdown').mouseleave(function(){
      $(this).slideToggle('medium'); 
    });

    // 酒详细页面
    $("a.wine_profile").fancybox();

    // 添加朋友、酒等
    $("a.btn_add.fancybox").fancybox({
        maxWidth        : 520,
        maxHeight       : 299,
        padding : 0,
        fitToView       : false,
        width           : '100%',
        height          : '100%',
        autoSize        : false,
        closeClick      : false,
        openEffect      : 'none',
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
    // 回复信息
    $("a.reply_conversation").fancybox({
        maxWidth        : 500,
        maxHeight       : 150,
        fitToView       : false,
        width           : '70%',
        height          : '70%',
        autoSize        : false,
        closeClick      : false,
        openEffect      : 'none',
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

    // 发送信息
    $("a.send_message").fancybox({
        maxWidth        : 500,
        maxHeight       : 260,
        fitToView       : false,
        width           : '70%',
        height          : '100%',
        autoSize        : false,
        closeClick      : false,
        openEffect      : 'none',
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

    // Mine 鼠标滑动显示编辑、删除按钮
    $(".mine.wine_follows .left  .box .item ").hover(function(){
        $(this).children(".delete").toggle();
        $(this).children(".edit").toggle();
    });


    $(".mine.simple_comments .left  .box .item ").hover(function(){
        $(this).children(".delete").toggle();
        $(this).children(".edit").toggle();
    });

    // 当使用ajax调用时， 显示laoding
    $(".ajax").bind("ajax:before", function(evt, data, status, xhr){
        $("#loading").toggle();
        // 这里也可以触发fancybox
    });
    $(".ajax").bind("ajax:success", function(evt, data, status, xhr){
        $("#loading").toggle();
    });
    $(".ajax").bind("ajax:failure", function(evt, data, status, xhr){
        $("#loading").html("由于网络故障， 请稍后重试");
    });
    $(".ajax").bind("ajax:error", function(evt, data, status, xhr){
      if (data.status == 401){
           window.location.replace("/login");
         }
    });
    
    // a变成submit
    $("a.submit").click(function(){
			$(this).parents("form").submit();
		});
   
});



    




