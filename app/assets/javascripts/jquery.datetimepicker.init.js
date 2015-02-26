jQuery(document).on('ready page:change', function() {
    var datetimefield = jQuery('.datetimepicker');
    datetimefield.datetimepicker({
        format: 'Y-m-d H:00:00',
        hours12: true,
        formatTime: 'H:i',
        lang: datetimefield.attr('lang') || datetimefield.parents('[lang]').attr('lang')
    });
});