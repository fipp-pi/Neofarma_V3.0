(function () {
  document.querySelectorAll('.admin-relatorios__period-chips [data-days]').forEach(function (btn) {
    btn.addEventListener('click', function () {
      var form = document.getElementById('reportFiltersForm');
      if (!form) return;
      var daysInput = form.querySelector('[name="days"]');
      var fromInput = form.querySelector('[name="from"]');
      var toInput = form.querySelector('[name="to"]');
      if (daysInput) daysInput.value = btn.getAttribute('data-days');
      if (fromInput) fromInput.value = '';
      if (toInput) toInput.value = '';
      document.querySelectorAll('.admin-relatorios__period-chips .admin-catalog__chip').forEach(function (c) {
        c.classList.remove('is-on');
      });
      btn.classList.add('is-on');
    });
  });
})();
