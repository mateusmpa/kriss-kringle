$(document).on 'turbolinks:load', ->
  $('.update-campaign input').bind 'blur', ->
    $('.update-campaign').submit()

  $('.update-campaign').on 'submit', (e) ->
    $.ajax e.target.action,
      type: 'PUT'
      dataType: 'json',
      data: $('.update-campaign').serialize()
      success: (data, text, jqXHR) ->
        Materialize.toast('Campanha atualizada', 4000, 'green')
      error: (jqXHR, textStatus, errorThrown) ->
        Materialize.toast('Problema na atualização da Campanha', 4000, 'red')
    return false

  $('.remove-campaign').on 'submit', (e) ->
    $.ajax e.target.action,
      type: 'DELETE'
      dataType: 'json',
      data: {}
      success: (data, text, jqXHR) ->
        $(location).attr('href', '/campaigns');
      error: (jqXHR, textStatus, errorThrown) ->
        Materialize.toast('Problema na remoção da Campanha', 4000, 'red')
    return false

  $('.raffle-campaign').on 'submit', (e) ->
    $.ajax e.target.action,
      type: 'POST'
      dataType: 'json',
      data: {}
      success: (data, text, jqXHR) ->
        Materialize.toast('Tudo certo, em breve os participantes receberão um e-mail!', 4000, 'green')
      error: (jqXHR, textStatus, errorThrown) ->
        Materialize.toast(jqXHR.responseText, 4000, 'red')
    return false
