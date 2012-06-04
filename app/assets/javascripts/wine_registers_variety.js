$(document).ready(function(){
   $("#create_variety").click(function(){
     if ($("#wines_register_variety_name_value").attr('value') == '' || $("#new_variety").attr('value') == ''){
         alert('葡萄品种或成分未填写值！');
         return false;
     }
     var name = $("#wines_register_variety_name_value").attr('value');
     var value = $("#new_variety").attr('value');
     var input_name = "<input type='hidden' name='wines_register[variety_name_value][]' value='" + name + "'/>";
     var input_value = "<input type='hidden' name='wines_register[variety_percentage_value][]' value='" + value + "'/>";
     var append_html= "<tr><td class='extra_attribute'>" + name + "</td><td class='extra_attribute'>" + value + "%</td>"+ input_name + input_value +"<th><a href='javascript:void(0);' class='delete_variety icon_delet2'></a></th></tr>";
     $("#variety_items").append(append_html);
     $("#wines_register_variety_name_value").attr('value', null);
     $("#new_variety").attr('value', null);
   });

    $("#add_detail_variety").click(function(){
        if ($("#variety_name").attr('value') == '' || $("#variety_percentage").attr('value') == ''){
            alert('葡萄品种或成分未填写值！');
            return false;
        }
        var name = $("#variety_name").attr('value');
        var value = $("#variety_percentage").attr('value');
        var input_name = "<input type='hidden' name='variety_percentage[variety_name][]' value='" + name + "'/>";
        var input_value = "<input type='hidden' name='variety_percentage[variety_percentage][]' value='" + value + "'/>";
        var append_html= "<li><span class='extra_attribute'>" + name + "</span><span class='extra_attribute'>" + value + "%</span>"+ input_name + input_value +"<a href='javascript:void(0);' class='delete_variety icon_delet2'></a></li>";
        $("#variety_items").append(append_html);
        $("#variety_name").attr('value', null);
        $("#variety_percentage").attr('value', null);
    });

  $("#create_special_comment").click(function(){
      if ($("#special_comment_name").attr('value') == '' || $("#special_comment_score").attr('value') == ''){
          alert('评论家或得分未填写！');
          return false;
      }
      var name = $("#special_comment_name").attr("value");
      var score = $("#special_comment_score").attr("value");
      var drinkable_begin = $("#special_drinkable_begin").attr('value');
      var drinkable_end = $("#special_drinkable_end").attr('value')
      var input_name = "<input name='special_comment[name][]' type='hidden' value='" + name + "'/>";
      var input_score = "<input name='special_comment[score][]' type='hidden' value='" + score + "'/>";
      var input_drinkable_begin = "<input name='special_comment[drinkable_begin][]' type='hidden' value='" + drinkable_begin + "'/>";
      var input_drinkable_end = "<input name='special_comment[drinkable_end][]' type='hidden' value='" + drinkable_end + "'/>";
      var append_html = "<tr><td class='extra_attribute'>" + name + "</td><td class='extra_attribute'>" + score + "</td><td class='extra_attribute'>" + drinkable_begin + ' - '+ drinkable_end + "</td>" + input_name + input_score + input_drinkable_begin + input_drinkable_end + "<th><a class='delete_special_comment icon_delet2' href='javascript:void(0);'></a></th></tr>";
      $("#special_comment_items").append(append_html);
      $("#special_comment_name").attr('value', null);
      $("#special_comment_score").attr('value', null);
  });

  $(".delete_variety, .delete_special_comment").live('click', function(){
    $(this).parent().parent().remove();
  });

  $("#edit_region_tree").click(function(){
    $("#region_tree_text, #region_tree").toggle();
  });
  $("#cancel_edit").click(function(){
    $("#region_tree_text, #region_tree").toggle();
    $(".select_region").val("");
  });


});

//add info_items
function add_fields(link, association, content) {
    var new_id = new Date().getTime();
    var regexp = new RegExp("new_" + association, "g");
    $(link).parent().parent().before(content.replace(regexp, new_id));
}