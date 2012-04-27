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

    // 下拉菜单

    $('a.arrow_down').click(function (event) {
        // $(this).preventDefault();
        event.preventDefault();
        $('ul.drop_down_menu').slideToggle('medium');
    });

    // 酒详细页面
    $("a.wine_profile").fancybox();

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

    // 评论
    $(".wine_profile .follow_wine1").fancybox({
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
    $(".ajax").bind("ajax:before", function(et, e){
        $("#loading").toggle();
        // 这里也可以触发fancybox
    });
    $(".ajax").bind("ajax:success", function(et, e){
        $("#loading").toggle();
    });
    $(".ajax").bind("ajax:failure", function(et, e){
        $("#loading").html("由于网络故障， 请稍后重试");
    });

});




