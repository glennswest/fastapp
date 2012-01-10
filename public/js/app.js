var json_error = function(s) {
  var error = null;
  try {
    JSON.parse(s);
  } 
  catch(err) {
    error = err.message;
  }
  return error;
}

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
  $('#edit_document input[type="submit"],#new_document input[type="submit"]').click(function(e){
    var error = json_error($('#document').val());
    if ( error ) {
      console.log(error);
      $('#json_error').html(error);
      $('#json_error').addClass('error');
      e.preventDefault();
    } else {
      $('#json_error').removeClass('error');
    }
  })
});
