$(document).ready(function(){
  $('a.popup').click(function(e){
    var dom_id = $(this).attr('data');
    $('#' + dom_id).show();
    var focus = $('#' + dom_id).attr('data')
    if ( focus ) {
      $('#' + focus).focus();
    }
  });
  $('div.popup a.close').click(function(e){
    $(this).closest('div.popup').fadeOut();
  });
});
