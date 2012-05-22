/*
 * jQuery MultiSelect UI Widget 1.9
 * Copyright (c) 2011 Eric Hynds
 *
 * http://www.erichynds.com/jquery/jquery-ui-manyselect-widget/
 *
 * Depends:
 *   - jQuery 1.4.2+
 *   - jQuery UI 1.8 widget factory
 *
 * Optional:
 *   - jQuery UI effects
 *   - jQuery UI position utility
 *
 * Dual licensed under the MIT and GPL licenses:
 *   http://www.opensource.org/licenses/mit-license.php
 *   http://www.gnu.org/licenses/gpl.html
 *
*/
(function($, undefined){

var manyselectID = 0;

$.widget("google.manyselect", {
  
  // default options
  options: {
  },

  _create: function(){
    var el = this.element.hide(),
      o = this.options,
      self = this;
    
    boxContainer = (this.boxContainer = $('<ol />'))
      .insertAfter( el );
    
    filter = (this.filter = $('<div class="ui-manyselect-filter">Filter: <input type="search" /></div>'))
        .insertAfter( el );
    filter.bind({
        keydown: function( e ){
          if (e.which === 13) e.preventDefault();
        },
        keyup: $.proxy(self._filterHandler, self),
        click: $.proxy(self._filterHandler, self)
    });

    // perform event bindings
    this._bindEvents();
    
    // build menu
    this.refresh( true );
  },
  
  _init: function(){
  },

  _filterHandler: function( e ){
    var term = $.trim( this.filter.find('input')[0].value.toLowerCase() );

    var rEscape = /[\-\[\]{}()*+?.,\\^$|#\s]/g;

    // speed up lookups
    rows = this.boxContainer.find('li');

    if( !term ){
      rows.show();
    } else {
      rows.hide();

      var regex = new RegExp(term.replace(rEscape, "\\$&"), 'gi');

      this._trigger( "filter", e, $.map(rows, function(v,i){
        if( v.innerHTML.toLowerCase().search(regex) !== -1 ){
          $(v).show();
          return v;
        }

        return null;
      }));
    }
  },

  
  refresh: function( init ){
    var el = this.element,
      o = this.options,
      boxContainer = this.boxContainer,
      id = el.attr('id') || manyselectID++; // unique ID for the label & option tags
    
    boxContainer.empty();
    
    // build items
    this.element.find('option').each(function(i){
      var $this = $(this), 
        title = $this.html(),
        value = this.value, 
        inputID = this.id || 'ui-manyselect-'+id+'-option-'+i, 
        $parent = $this.parent(), 
        isDisabled = $this.is(':disabled'), 
        isSelected = $this.is(':selected'), 
        labelClasses = ['ui-corner-all'],
        label, li;
      
      if( value.length > 0 ){
        if( isDisabled ){
          labelClasses.push('ui-state-disabled');
        }
        
        li = $('<li />')
          .addClass('ui-widget-content')
          .addClass(isDisabled ? 'ui-manyselect-disabled' : '')
          .addClass(isSelected ? 'ui-selected' : '')
          .appendTo( boxContainer );
        $('<span>'+title+'</span>').appendTo(li)
      }
    });

    var self = this;
    boxContainer.selectable()
      .bind('selectable' + 'selected', function(ev, el) {
          val = $(el['selected']).text();
          tags = self.element.find('option');
          tags.filter(function(){
            return this.text === val;
            }).attr('selected', 'selected');
          })
      .bind('selectable' + 'unselected', function(ev, el) {
          val = $(el['unselected']).text();
          tags = self.element.find('option');
          tags.filter(function(){
            return this.text === val;
            }).attr('selected', '');
          })
    ;

    // broadcast refresh event; useful for widgets
    if( !init ){
      this._trigger('refresh');
    }
  },
  
  // updates the button text.  call refresh() to rebuild
  update: function(){
    return true;
  },
  
  // binds events
  _bindEvents: function(){
    var self = this;
  },

  enable: function(){
    this._toggleDisabled(false);
  },
  
  disable: function(){
    this._toggleDisabled(true);
  },
  
  getChecked: function(){
    //return this.menu.find('input').filter(':checked');
  },
  
  destroy: function(){
    // remove classes + data
    $.Widget.prototype.destroy.call( this );
    
    this.menu.remove();
    this.element.show();
    
    return this;
  },
  
  widget: function(){
    return this.menu;
  },
  
  // react to option changes after initialization
  _setOption: function( key, value ){
    var menu = this.menu;
    
    switch(key){
      case 'classes':
        menu.add(this.button).removeClass(this.options.classes).addClass(value);
        break;
    }
    
    $.Widget.prototype._setOption.apply( this, arguments );
  }
});

})(jQuery);
