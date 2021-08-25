$(document).ready(function() {
  const errors = $(this).find('span.error');
  const hasError = errors.length > 0;
  if (hasError) {
    errors.each(function() {
      const text = $(this).text();
      const [key, value] = text.split(':');
      const input = $(document).find(`input[id$=_${key}]`);
      console.log(input);
      input.parent().addClass('error');
      input.parent().append(`<span class="error-message">${value}.</span>`);
    });
  }
});
