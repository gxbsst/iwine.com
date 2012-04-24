$(document).ready(function(){
   $("#create_variety").click(function(){
     if ($("#wines_register_variety_name_value").attr('value') == '' || $("#new_variety").attr('value') == ''){
         alert('葡萄品种或成分未填写值！');
         return false;
     }
     var name, value;
     name = $("#wines_register_variety_name_value").attr('value');
     value = $("#new_variety").attr('value');
     $("#variety_items").append("<li>" + name + "&nbsp;&nbsp;&nbsp;&nbsp;" + value + "</li>");
     $("#variety_items").append("<input type='hidden' name='wines_register[variety_name_value][]' value='" + name + "'/>");
     $("#variety_items").append("<input type='hidden' name='wines_register[variety_percentage_value][]' value='" + value + "'/>");
     $("#wines_register_variety_name_value").attr('value', null);
     $("#new_variety").attr('value', null);
   });
});