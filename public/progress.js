if (typeof GlobalNameSpace === 'undefined') {GlobalNameSpace = {}}
(function($){
  $(function() {
    GlobalNameSpace.upload_id = $('.upload').find('[name=upload_id]').val();
    var uploadNum = 0;
    var template$ = $('.upload').clone();
    template$.find('input').each(function(){$(this).val(null)});
    $('.upload form input[name=file]').change(fileUploadHandler);
    $('.title form').submit(function(){return false;});
    $('a.new-upload').click(function() {
      var newUpload$ = template$.clone();
      newUpload$.find('form input[name=upload_id]').val(GlobalNameSpace.upload_id + '-j' + ++uploadNum);
      newUpload$.appendTo($('.uploads-container')).find('form input[name=file]').change(fileUploadHandler);
      return false;
    });
  });
}(jQuery));


var fileUploadHandler = function() {
  try {
    if ($(this).val()) {
      var form$ = $(this).parent('form');
      var upload$ = $(this).parents('.upload');
      var bar$ = upload$.find('.progress-bar');
      var percents$ = upload$.find('.percents');
      var iframe$ = $('<iframe>').css({width:0, height: 0, position: 'absolute', top: '-3000px'}).
        appendTo($('body'));
      var iframeDoc = iframe$[0].contentWindow.document;
      var upload_id = form$.find('[name=upload_id]').val();
      iframeDoc.open();
      iframeDoc.write('<html><head></head><body></body></html>');
      iframeDoc.close();
      var iframeBody$ = $(iframeDoc.body);

      var saveTitle = function() {
        $.ajax({url: '/save',
          type: 'POST',
          data: {title: upload$.find('.title input').val(),
            path: upload$.find('.saved-file .file-path').text()},
          success: function() {
            upload$.find('.title .save-button').hide();
            upload$.find('.title .saved').show();
            upload$.find('.title input').keyup(function() {
              upload$.find('.title .saved').hide();
              upload$.find('.title .save-button').show();
            });
          }});
        return false;
      };

      var updateSavedFile = function() {
        if ($(iframe$[0].contentWindow.document.body).find('form').length == 0) {
          upload$.find('.saved-file .file-path').text($(iframe$[0].contentWindow.document.body).text());
          clearInterval(iframe$.data('timer'));
          saveTitle();
        }
      };

      var updateUpload = function() {
        $.ajax({url: '/progress/?upload_id='+upload_id,
          dataType: 'JSON',
          type: 'GET',
          success: function(result) {
            if (result.state == 'uploading') {
              result.percents = Math.floor((result.received / result.size)*1000)/10;
              bar$.animate({width: result.percents+'%'}, 1000);
              percents$.text(result.percents + '%');
            }
            if (result.state === 'error' || result.state === 'processing') {
              if (result.state === 'error'){clearTimeout(upload$.data('timer'));}
              upload$.find('.progress-bar').animate({width: '100%'}, 1000);
              upload$.find('.saved-file .file-path').text(result.state);
              upload$.find('.progress').fadeOut(function() {
                upload$.find('.saved-file').fadeIn();
              });
            }
            if (result.state == 'done') {
              clearTimeout(upload$.data('timer'));
              upload$.find('.progress-bar').animate({width: '100%'}, 1000);
              percents$.text('Done');
              updateSavedFile();
              upload$.find('.progress').fadeOut(function() {
                upload$.find('.saved-file').fadeIn();
              });
            }
          }});
      };

      upload$.find('.title .save-button').click(saveTitle);
      form$.remove().appendTo(iframeBody$);
      form$.attr('action', form$.attr('action') + '?upload_id='+ upload_id);
      upload$.find('.progress').show();
      upload$.data('timer', setInterval(updateUpload, 1000));
      form$.submit();
      return false;
    }
  } catch (e) {alert(e);}
};