jQuery(function(){
    jQuery('input[type=button]').addClass('btn');
    jQuery('input[type=submit]').addClass('btn btn-inverse');  
    jQuery('#nav-single a').addClass('btn btn-info');

    if(jQuery(window).width()>=800){
        jQuery('#topmenu .dropdown').hover(function() {
            jQuery(this).find('.dropdown-menu').first().stop(true, true).delay(250).slideDown();

        }, function() {
            jQuery(this).find('.dropdown-menu').first().stop(true, true).delay(100).slideUp();

        });
        jQuery('#topmenu .dropdown > a').click(function(){
            location.href = this.href;
        });} else {
        jQuery('.dropdown').click(function(e){
            e.preventDefault();
            jQuery(this).find('.dropdown-menu').first().stop(true, true).slideToggle();
        });
    }

});