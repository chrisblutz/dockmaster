$(function(){
  $(".toggle").click(function(){
    $(this).next().slideToggle("fast");
  });
});
