$(document).ready(function() {
  $('header ul li.has-dropdown').hover(function() {
    $(this).find('ul').slideDown();
  });

  $('header').mouseleave(function() {
    $('header ul li.has-dropdown ul').slideUp();
  });

  $('header > ul:not(.dropdown) li').hover(function() {
    if ($(this).hasClass('has-dropdown')) return;
    const parent = $(this).parent();
    if (parent.hasClass('dropdown')) return;
    $('header ul li.has-dropdown ul').slideUp();
  });

  $.fn.datepicker.dates['fr'] = {
    days: ["dimanche", "lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi"],
    daysShort: ["dim.", "lun.", "mar.", "mer.", "jeu.", "ven.", "sam."],
    daysMin: ["d", "l", "ma", "me", "j", "v", "s"],
    months: ["janvier", "février", "mars", "avril", "mai", "juin", "juillet", "août", "septembre", "octobre", "novembre", "décembre"],
    monthsShort: ["janv.", "févr.", "mars", "avril", "mai", "juin", "juil.", "août", "sept.", "oct.", "nov.", "déc."],
    today: "Aujourd'hui",
    monthsTitle: "Mois",
    clear: "Effacer",
    weekStart: 1,
    format: "dd/mm/yyyy"
  };

  /*$(window).on('scroll', function(e) {
    const scroll = $(window).scrollTop();
    if (scroll == 0) {
      $('aside').css('top', 'auto');
    } else {
      $('aside').css('top', '0');
    }
  });*/

  $('section a.buy-multiple').on('click', function(e) {
    e.preventDefault();
    const professionnal = $(this).data('professionnal') == true;
    const productPriceID = $(this).data('product-price-id');
    if (professionnal) {
      window.location.href = `/ticket_purchases/new?product_price_id=${productPriceID}`;
    } else {
      $.ajax({
        method: 'POST',
        url: '/cart/items',
        data: { authenticity_token: $('[name="csrf-token"]')[0].content, product_price_id: productPriceID },
        success: function() {
          window.location.href = '/checkout';
        },
      });
    }
  });

  $('table#mini-calendar span.date').on('click', function() {
    const productPriceID = $('aside').data('product-price-id');
    const startTime = $(this).data('date-time');
    $.ajax({
      method: 'POST',
      url: '/cart/items',
      data: { authenticity_token: $('[name="csrf-token"]')[0].content, product_price_id: productPriceID, start_time: startTime },
      success: function() {
        window.location.href = '/checkout';
      },
    });
  });

  $('input#coupon').on('keyup', function() {
    const val = $(this).val().trim();
    if (val == '') {
      $('form#payment_form button#apply_coupon').slideUp();
      $('form#payment_form button#pay').slideDown();
    } else {
      $('form#payment_form button#pay').slideUp();
      if ($('form#payment_form button#apply_coupon').length == 0) {
        $('form#payment_form').append('<button type="button" id="apply_coupon">Appliquer le code promo</button>');
      }
      $('form#payment_form button#apply_coupon').slideDown();
      $('button#apply_coupon').on('click', function() {
        $('form#coupon_form').submit();
      });
    }
  });

  $('a#cancel-reservation').on('click', function() {
    if (confirm('Etes-vous sûr de vouloir annuler cette réservation ?')) {
      const reservationID = $(this).data('reservation-id');
      $.ajax({
        method: 'DELETE',
        url: `/reservations/${reservationID}`,
        data: { authenticity_token: $('[name="csrf-token"]')[0].content },
        success: function(date) {
          window.location.href = '/reservations';
        },
      });
    }
  });
  
  $('table#mini-calendar + a#see-more').on('click', function() {
    $('table#mini-calendar tr.hidden').slideDown();
    $(this).slideUp();
  });

  $('table#mini-calendar th#previous').on('click', function() {
    const firstDate = $('table#mini-calendar th:first-child').next().data('date');
    const startFrom = moment(firstDate).subtract(4, 'days').format('YYYY-MM-DD');
    const href = `${window.location.pathname}?start_from=${startFrom}`;
    window.location.href = href;
  });

  $('table#mini-calendar th#next').on('click', function() {
    const firstDate = $('table#mini-calendar th:last-child').prev().data('date');
    const startFrom = moment(firstDate).add(1, 'day').format('YYYY-MM-DD');
    const href = `${window.location.pathname}?start_from=${startFrom}`;
    window.location.href = href;
  });

  $('select#to_be_paid_online').on('change', function() {
    const val = $(this).val();
    const reservationID = $(this).closest('form').find('input#reservation_id').val();
    $.ajax({
      method: 'PATCH',
      url: `/reservations/${reservationID}`,
      data: { authenticity_token: $('[name="csrf-token"]')[0].content, reservation: { to_be_paid_online: val } },
      success: function() {
        window.location.reload();
      },
    });
  });
});
