
(function($) {
    "use strict"; // Start of use strict

    // jQuery for page scrolling feature - requires jQuery Easing plugin
    $('a.page-scroll').bind('click', function(event) {
        var $anchor = $(this);
        $('html, body').stop().animate({
            scrollTop: ($($anchor.attr('href')).offset().top - 50)
        }, 1250, 'easeInOutExpo');
        event.preventDefault();
    });

    // Highlight the top nav as scrolling occurs
    $('body').scrollspy({
        target: '.navbar-fixed-top',
        offset: 51
    });

    // Closes the Responsive Menu on Menu Item Click
    $('.navbar-collapse ul li a').click(function(){
            $('.navbar-toggle:visible').click();
    });

    // Offset for Main Navigation
    $('#mainNav').affix({
        offset: {
            top: 100
        }
    })

    $(window).scroll(()=>{
        var wintop = $(window).scrollTop(), docheight = $(document).height(), winheight = $(window).height();
        var scrollTrigger = 150;

        if ( wintop > scrollTrigger) {
            $('.back-top').fadeIn(750);
        } else {
            $('.back-top').fadeOut(750);
        }
    })

})(jQuery); // End of use strict