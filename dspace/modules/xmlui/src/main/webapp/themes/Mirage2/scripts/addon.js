(function($) {
	$( "div[class*='community-browser-row']" ).each(function() {
                if ( $(this).find('a').size() == 0) {
                        $(this).hide();
                }
        });

	$("#main-container").append('<span title="To Top" id="totop" class="hidden-xs hidden-sm">&#8963;</span>');
            $(window).scroll( function(){
                $(window).scrollTop()>500?($("#totop:hidden").fadeIn()):$("#totop:visible").fadeOut()
            });

            $("#totop").click(function(){
                $("html, body").animate({scrollTop:0})
        });

})(jQuery);
