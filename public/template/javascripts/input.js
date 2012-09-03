// JavaScript Document
function clearDefaultText (el,message)
{
var obj = el;
if(typeof(el) == "string")
obj = document.getElementById(id);
if(obj.value == message)
{
obj.value = "";
}
obj.onblur = function()
{
if(obj.value == "")
{
   obj.value = message;
}
}
}