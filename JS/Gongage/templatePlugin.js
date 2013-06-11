/*
    Created By:     Steven Gongage (5/21/2013)
    Purpose:        This is an example of a jQuery plugin with an exposed API and options properties.

    Originally created after reading this article:
        http://alistapart.com/article/the-design-of-code-organizing-javascript


*/




(function($) {
    $.jPanelMenu = function(options) {
        var jpm = {
            // Options properties give a default set of options AND allow options object passed in to override existing objects by using the 'extend()' jQuery method
            options: $.extend({
                'animated': true,
                'duration': 500,
                'direction': 'left'
            }, options),

            // Just an example PUBLIC method...
            openMenu: function( ) {
                this.setMenuStyle( );
            },
            // Just an example PUBLIC method...
            closeMenu: function( ) {
                this.setMenuStyle( );
            },
            // Just an example PRIVATE method...
            setMenuStyle: function( ) {  }
        };

        // Returns an object with the exposed (public) methods included
        return {
            open: jpm.openMenu,    
            close: jpm.closeMenu,
            someComplexMethod: function( ) {  }
        };
    };
})(jQuery);