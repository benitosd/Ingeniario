// app/assets/javascripts/families.js

$(document).on('turbolinks:load', function() {
    $('.btn-edit').on('click', function() {
      var id = $(this).data('id');
      var row = $('#family_' + id);
      row.find('.editable').each(function() {
        var field = $(this).data('field');
        var currentValue = $(this).text();
        $(this).html('<input type="text" class="form-control" data-field="' + field + '" value="' + currentValue + '"/>');
      });
      $(this).text('Guardar').removeClass('btn-warning').addClass('btn-success').addClass('btn-save');
    });
  
    $(document).on('click', '.btn-save', function() {
      var id = $(this).data('id');
      var row = $('#family_' + id);
      var data = {};
      row.find('.editable input').each(function() {
        var field = $(this).data('field');
        var value = $(this).val();
        data[field] = value;
      });
  
      $.ajax({
        url: '/families/' + id + '/update_inline',
        method: 'PATCH',
        data: { family: data },
        success: function(response) {
          if (response.success) {
            row.find('.editable').each(function() {
              $(this).text(response.family[$(this).data('field')]);
            });
            $('.btn-save').text('Editar').removeClass('btn-success').addClass('btn-warning').addClass('btn-edit');
          } else {
            alert('Error: ' + response.errors.join(', '));
          }
        }
      });
    });
  });
  
