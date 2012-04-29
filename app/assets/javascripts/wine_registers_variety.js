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
     var append_html= "<li><span class='extra_attribute'>" + name + "</span><span class='extra_attribute'>" + value + "%</span>"+ input_name + input_value +"<span class='delete_variety'>删除</span></li>";
     $("#variety_items").append(append_html);
     $("#wines_register_variety_name_value").attr('value', null);
     $("#new_variety").attr('value', null);
   });

  $("#create_special_comment").click(function(){
      if ($("#special_comment_name").attr('value') == '' || $("#special_comment_score").attr('value') == ''){
          alert('评论家或得分未填写！');
          return false;
      }
      var name = $("#special_comment_name").attr("value");
      var score = $("#special_comment_score").attr("value");
      var drinkable_begin = $("#wines_register_special_comments_drinkable_begin_1i").attr('value');
      var drinkable_end = $("#wines_register_special_comments_drinkable_end_1i").attr('value')
      var input_name = "<input name='special_comment[name][]' type='hidden' value='" + name + "'/>";
      var input_score = "<input name='special_comment[score][]' type='hidden' value='" + score + "'/>";
      var input_drinkable_begin = "<input name='special_comment[drinkable_begin][]' type='hidden' value='" + drinkable_begin + "'/>";
      var input_drinkable_end = "<input name='special_comment[drinkable_end][]' type='hidden' value='" + drinkable_end + "'/>";
      var append_html = "<li><span class='extra_attribute'>" + name + "</span><span class='extra_attribute'>" + score + "</span><span class='extra_attribute'>" + drinkable_begin + ' - '+ drinkable_end + "</span>" + input_name + input_score + input_drinkable_begin + input_drinkable_end + "<span class='delete_special_comment'>删除</span></li>";
      $("#special_comment_items").append(append_html);
      $("#special_comment_name").attr('value', null);
      $("#special_comment_score").attr('value', null);
  });

  $(".delete_variety, .delete_special_comment").live('click', function(){
    $(this).parent().remove();
  });

  $("#edit_region_tree").click(function(){
     $("#region_tree_text, #region_tree").toggle();
  });
  $("#cancel_edit").click(function(){
      $("#region_tree_text, #region_tree").toggle();
      $(".select_region").val("");
  });

});