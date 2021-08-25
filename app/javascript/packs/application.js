// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("@rails/activestorage").start()
require("channels")
require("jquery");

//require("custom/jquery-3.6.0");
require("custom/jquery-ui.min");
require("custom/jquery.multiselect");
require("custom/jquery.datetimepicker.full.min");

global.$ = require('jquery')

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

jQuery.expr[':'].contains = function(a, i, m) {
  return jQuery(a).text().toUpperCase()
  .indexOf(m[3].toUpperCase()) >= 0;
};

$(document).ready(function() {
  $('select[multiple]').multiselect({
    texts: {
      placeholder: 'Sélectionner..',
    },
  });

  $('select[multiple]').each(function() {
    const count = $(this).find('option:checked').length;
    if (count == 0) return;
    const id = $(this).attr('class').replace(/jqmsLoaded /, '');
    const target = $(`div#${id}`);
    const text = target.find('button span').text();
    target.find('button span').text(`${count} choix sélectionné${count > 1 ? 's' : ''}`);
  });

  $('button[data-target], a[data-target], tr[data-target], td[data-target], div.reservation[data-target], div.blocker[data-target], ul#tabs li[data-target]').on('click', function(e) {
    const type = $(this).prop('tagName');
    if (type == 'TD' && e.target !== this) {
      return;
    }
    e.preventDefault();
    $('div.modal:visible').slideUp();
    const target = $(this).data('target');
    $('div#overlay').slideDown();
    $(target).slideDown();
    $(target).find('p:first-child input, p:first-child select').focus();
    window.scrollTo({
      top: 0,
      behavior: 'smooth'
    });
  });

  $('ul#tabs li[data-target]').on('click', function(e) {
    const reservationStartTime = $('input#reservation_start_time').val();
    if (reservationStartTime) {
      $('input#blocker_start_time').val(reservationStartTime);
      const oneHourAfter = moment(new Date(reservationStartTime)).add(1, 'hour');
      $('input#blocker_end_time').val(oneHourAfter);
    }
  });

  $('td[data-target="#new-reservation"]').on('click', function() {
    setTimeout(function() {
      const currentProductPriceID = $('div.modal:visible').find('input#reservation_product_price_id').val();
      const currentProductName = $('div.modal:visible').find('span#reservation_product_name').text();
      const currentStartTime = $('div.modal:visible').find('input#reservation_start_time').val();
      sessionStorage.setItem('current_product_price_id', currentProductPriceID);
      sessionStorage.setItem('current_product_name', currentProductName);
      sessionStorage.setItem('current_start_time', currentStartTime);
    }, 500);
  });

  const isReservationsView = window.location.pathname == '/reservations';
  if (isReservationsView) {
    if (window.location.search.includes('?client_id=')) {
      const locationParts = window.location.search.split('?client_id=');
      const clientID = locationParts[1];
      $('div#overlay').slideDown();
      $('div.modal#new-reservation').slideDown();
      $('div.modal#new-reservation').find('select#reservation_client_id').val(clientID);
      if (sessionStorage.getItem('current_product_price_id') && sessionStorage.getItem('current_product_name') && sessionStorage.getItem('current_start_time')) {
        $('div.modal:visible').find('input#reservation_product_price_id').val(sessionStorage.getItem('current_product_price_id'));
        $('div.modal:visible').find('span#reservation_product_name').text(sessionStorage.getItem('current_product_name'));
        $('div.modal:visible').find('input#reservation_start_time').val(sessionStorage.getItem('current_start_time'));
      }
    }
  }

  const isPaymentsView = window.location.pathname == '/paiements';
  if (isPaymentsView) {
    if (window.location.search.includes('?client_id=')) {
      const locationParts = window.location.search.split('?client_id=');
      const clientID = locationParts[1];
      $('div#overlay').slideDown();
      $('div.modal#new-payment').slideDown();
      $('div.modal#new-payment').find('select#payment_client_id').val(clientID);
    }
  }

  const forcedModal = $('div.modal.force');
  if (forcedModal.length > 0) {
    $('div#overlay').slideDown();
    $(forcedModal).slideDown();
  }
  const fieldWithErrors = $('div.field_with_errors');
  if (fieldWithErrors.length > 0) {
    const modal = fieldWithErrors[0].closest('div.modal');
    $('div#overlay').slideDown();
    $(modal).slideDown();
  }

  $('div.modal button.cancel, div.modal svg.fa-times').on('click', function(e) {
    e.preventDefault();
    $('div#overlay, div.modal').slideUp();
  });

  $(document).on('keyup', function(e) {
    if (e.key == 'Escape') {
      $('div#overlay, div.modal, div.dropdown').slideUp();
    }
  });

  $('div#search input:not(#clients_search)').on('keyup', function(e) {
    const val = $(this).val().trim();
    if (val) {
      $('table tr:not(:first-child)').hide();
      $(`table tr td:contains(${val})`).parent().show();
    } else {
      $('table tr').show();
    }
  });

  $('div#search input#clients_search').on('keyup', function(e) {
    if (e.key === 'Enter' || e.keyCode === 13) {
      const val = $(this).val().trim();
      window.location.href = `/clients?search=${val}`;
    }
  });

  $('button#export').on('click', function() {
    window.location.href = '/clients/exports';
  });

  $('div.modal table a.new-line').on('click', function(e) {
    e.preventDefault();
    const row = $(this).closest('tr');
    const modal = $(this).closest('div.modal');
    const professionnal = modal.find('h2').text().includes('pro') ? '1' : '0';

    const newRow = `<tr><td><input type="hidden" name="product_prices[][professionnal]" value="${professionnal}"><input type="number" name="product_prices[][session_count]"></td><td><input type="number" name="product_prices[][total]"></td><td><i class="fas fa-trash"></i></td></tr>`;
    $(newRow).insertBefore(row);
  });

  $('div.modal table a.new-line-survey').on('click', function(e) {
    e.preventDefault();
    const row = $(this).closest('tr');
    const modal = $(this).closest('div.modal');

    const newRow = '<tr><td><textarea name="survey_questions[][body]"></textarea></td></tr>';
    $(newRow).insertBefore(row);
  });

  $('div.modal table svg.fa-trash').on('click', function() {
    if (confirm('Etes-vous sûr de vouloir supprimer ce tarif ?')) {
      const row = $(this).closest('tr');
      row.remove();
    }
  });

  $('div.modal').each(function() {
    const modal = $(this);
    const errors = $(this).find('span.error');
    const hasError = errors.length > 0;
    if (hasError) {
      errors.each(function() {
        const text = $(this).text();
        const [key, value] = text.split(':');
        const input = modal.find(`input[id$=_${key}]`);
        input.parent().addClass('error');
        input.parent().append(`<span class="error-message">${value}.</span>`);
      });
    }
  });

  $('div.modal input[required], div.modal textarea[required], div.modal select[required]').each(function() {
    const input = $(this);
    const label = input.parent().find('label');
    label.append('<span class="red">*</span>');
  });

  $('div.modal a.purge-thumbnail').on('click', function(e) {
    e.preventDefault();
    const link = $(this);
    const modal = $('div.modal:visible');
    const input = modal.find('input#product_purge_thumbnail');
    input.val('1');
    modal.find('img#thumbnail').hide();
    $(this).hide();
    const inputFile = modal.find('input#product_thumbnail');
    inputFile.slideDown();
  });

  $('div.modal a.purge-disclaimer').on('click', function(e) {
    e.preventDefault();
    const link = $(this);
    const modal = $('div.modal:visible');
    const input = modal.find('input#product_purge_disclaimer');
    input.val('1');
    modal.find('a#disclaimer').hide();
    $(this).hide();
    const inputFile = modal.find('input#product_disclaimer');
    inputFile.slideDown();
  });

  $('section a.purge-image').on('click', function(e) {
    e.preventDefault();
    const imageID = $(this).data('image-id');
    if (confirm('Etes-vous sûr de vouloir supprimer cette image ?')) {
      const url = `${window.location.href}/images/${imageID}`;
      $.ajax({
        method: 'DELETE',
        url,
        success: function() {
          window.location.reload();
        }
      });
    }
  });

  $('td[data-target="#new-reservation"]').on('click', function() {
    const productPriceID = $(this).data('product-price-id');
    const productName = $(this).data('product-name');
    $('div.modal:visible').find('input#reservation_product_price_id').val(productPriceID);
    $('div.modal:visible').find('span#reservation_product_name').text(productName);
    const date = $(this).data('date');
    let hour = $(this).data('hour');
    if (hour < 10) {
      hour = `0${hour}`;
    }
    const dateTime = `${date}T${hour}:00`;
    $('div.modal:visible').find('input#reservation_start_time').val(dateTime);
  });

  $('div.modal button.red').on('click', function() {
    const pathname = $(this).data('pathname') || window.location.pathname;
    let redirectTo = $(this).data('redirect-to');
    if (!redirectTo) {
      const pathnameParts = pathname.split('/');
      pathnameParts.pop();
      redirectTo = pathnameParts.join('/');
    }
    let message = $(this).data('message');
    if (!message) {
      message = 'Etes-vous sûr de vouloir supprimer ?';
    }
    if (confirm(message)) {
      $.ajax({
        method: 'DELETE',
        url: pathname,
        success: function(data) {
          window.location.href = redirectTo;
        }
      });
    }
  });

  $('div#search select#filter').on('change', function() {
    const pathname = window.location.pathname;
    const franchiseID = $(this).val();
    if (franchiseID == 'all') {
      window.location.href = pathname;
    } else {
      window.location.href = `${pathname}?franchise_id=${franchiseID}`;
    }
  });

  if (!window.location.search.includes('franchise_id=')) {
    const filterSelect = $('div#search select#filter');
    const selected = filterSelect.val();
    if (selected == 'all') {
      return;
    }
    const currentFranchiseID = filterSelect.data('current-franchise-id');
    filterSelect.val(currentFranchiseID);
  }

  $('a#client-show-link').on('click', function() {
    const clientID = $('div.modal:visible').find('select#reservation_client_id').val();
    window.open(`/clients/${clientID}`, '_blank');
  });

  const isCampaignView = window.location.pathname.match(/\/campaigns\/.+/);
  if (isCampaignView) {
    const selectedObjectives = $('div#selected-objectives').text();
    $('select#campaign_filters_objectives').multiselect('select', selectedObjectives);

    $('button#send_campaign').on('click', function() {
      if (confirm('Etes-vous sûr de vouloir envoyer la campagne ?')) {
        const campaignID = $(this).data('campaign-id');
        $.ajax({
          method: 'POST',
          url: `/campaigns/${campaignID}/send_now`,
          success: function() {
            window.location.reload();
          }
        });
      }
    });
  }

  $('button#fetch-templates').on('click', function() {
    $.ajax({
      method: 'POST',
      url: '/templates/upsert',
      success: function() {
        window.location.reload();
      }
    });
  });

  const getFormData = ($form) => {
    var unindexed_array = $form.serializeArray();
    var indexed_array = {};

    $.map(unindexed_array, function(n, i){
      indexed_array[n['name']] = n['value'];
    });

    return indexed_array;
  };

  $('form#new_reservation').on('submit', function(e) {
    e.preventDefault();
    const action = $(this).attr('action');
    const data = getFormData($(this));
    $.ajax({
      method: 'POST',
      url: action,
      data, 
      success: function() {
        window.location.reload();
      },
      error: function(xhr) {
        let error = xhr.responseJSON.error;
        if (error == 'INVALID_CAPACITY') {
          error = 'Un RDV est déjà programmé sur ce créneau horaire'
        }
        alert(error);
      },
    });
  });
});
