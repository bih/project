jQuery(document).on('ready page:change', function() {
  Date.parseDate = function( input, format ){
    return moment(input,format).toDate();
  };
  Date.prototype.dateFormat = function( format ){
    return moment(this).format(format);
  };

  var datetimefield = jQuery('.datetimepicker');
  datetimefield.datetimepicker({
    format: 'YYYY-MM-DD HH:00:00',
    formatTime: 'HH:00',
    lang: datetimefield.attr('lang') || datetimefield.parents('[lang]').attr('lang'),
    onGenerate: function(current_time, input) {
      var date = moment(input.val()).format("YYYY-MM-DD HH:00:00");

      if(date !== input.val() && date !== "Invalid date") {
        input.val(date);
      }
    }
  });

  var datefield = jQuery('.datepicker');
  datefield.datetimepicker({
    timepicker: false,
    defaultDate: new Date(Date.parse(datefield.data('day'))),
    onChangeDateTime: function(dp, input) {
      var date = dp.dateFormat("DD-MM-YYYY");
      datefield.datetimepicker('hide');

      if(date === moment(Date.now() - (60*60*24*1000)).format("DD-MM-YYYY")) {
        datefield.find('span').text("yesterday...");
      } else if(date === moment().format("DD-MM-YYYY")) {
        datefield.find('span').text("today...");
      } else if(date === moment(Date.now() + (60*60*24*1000)).format("DD-MM-YYYY")) {
        datefield.find('span').text("tomorrow...");
      } else {
        datefield.find('span').text("on " + dp.dateFormat("Do MMMM YYYY") + "...");
      }

      window.location = '?date=' + date;
    },
    lang: datetimefield.attr('lang') || datetimefield.parents('[lang]').attr('lang')
  });
});