
!function($) {

  var ModalSingleSelector = function(element, options) {
    this.options = options;
    this.$element = $(element);
    $.fn.modal_form.Constructor.prototype.init.apply(this);
    this.init();
  };

  ModalSingleSelector.prototype = $.extend({}, $.fn.modal_form.Constructor.prototype, {

    constructor: ModalSingleSelector

  , mappers: {
      relationships: {
        options_load_item: function(o) { return o; }
      , options_add_item: function(o) { return o; }
      , current_load_item: function(o) { return o; }
      , current_add_item: function(o, id) { return { id: id, object: o } }
      }
  }

  , init: function() {
      var self = this;
      this.mapper = 'relationships';

      this.objects = {};

      // Register interface event listeners
      this.$element
        .on('click', '.source li', $.proxy(this.handle_select, this));

      // Register internal listeners
      this.$element
        .on('list-load-item', '.source', $.proxy(this.load_option, this))
        .on('list-add-item',  '.source', $.proxy(this.add_option, this))
        .on('list-update-item', '.source', $.proxy(this.update_option, this))
        .on('list-delete-item', '.source', $.proxy(this.delete_option, this))
        .on('delete-object', $.proxy(this.delete_object, this))

      // Wait for initial modal 'loaded' event
      this.$element
        .on('loaded', $.proxy(this.load_lists, this));
    }

    /* If the object has a single key, return its value */
  , object_record: function(o) {
      var i, val = null;
      for (i in o) {
        if (o.hasOwnProperty(i)) {
          if (val) return o;
          val = o[i];
        }
      }
      if (val)
        return val;
      else
        return o;
    }

  , store_object: function(o) {
      var item = this.object_record(o);
      this.objects[item.id] = item;
    }

  , delete_object: function(e, data, xhr) {
      this.$source().trigger('list-delete-item', data);
    }

  , $source: function() { return this.$element.find('.source'); }

  , mark_item_selected: function($el) {
      $el.
        find('[data-toggle="selector-list-select"]').
          removeClass('widgetbtn').
          addClass('widgetbtnoff').
          find('i').
            removeClass('grcicon-chevron-right').
            addClass('grcicon-check-green');
    }

  , mark_item_unselected: function($el) {
      $el.
        find('[data-toggle="selector-list-select"]').
          removeClass('widgetbtnoff').
          addClass('widgetbtn').
          find('i').
            removeClass('grcicon-check-green').
            addClass('grcicon-chevron-right');
    }

  , load_lists: function(e) {
      var self = this
        , $source = this.$source()
        , source_url = $source.data('list-data-href')
        ;

      $.getJSON(source_url, function(data, status, xhr) {
        $source.empty();
        self.objects = {};
        $.each(data, function(i, item) {
          $source.trigger('list-load-item', item);
        });
      });
    }

  , load_option: function(e, item) {
      this.$source().tmpl_additem(item);

      this.store_object(item);
    }

  , add_option: function(e, item) {
      var $added_item
        , $source = this.$source()
        , data = this.mappers[this.mapper].options_add_item(item)
        ;

      $added_item = $source.find('[data-id="' + data.id + '"]');
      $source.tmpl_additem(data);

      this.store_object(item);
    }

  , update_option: function(e, item) {
      var $updated_item
        , $source = this.$source()
        , data = this.mappers[this.mapper].options_add_item(item)
        ;

      $updated_item = $source.find('[data-id="' + data.id + '"]');
      if ($updated_item.length > 0) {
        $updated_item.replaceWith($.tmpl.render_items($source, [item]));
      }

      this.objects[data.id] = data;
    }

  , delete_option: function(e, item) {
      var $item
        , $source = this.$source()
        ;

      $item = $source.find('[data-id="' + item.id + '"]');
      $item.remove();

      delete this.objects[item.id];
    }

  , handle_select: function(e) {
      // Don't select if the click was on an edit button
      if ($(e.target).closest('a[data-toggle]').length > 0)
        return;

      e.preventDefault();
      var $item = $(e.currentTarget).closest('li')
        , data = $item.data()
        , id = $item.data('id')
        ;

      this.$element.trigger('modal:select', this.objects[$item.data('id')]);
    }
  });

  $.fn.modal_single_selector = function(option) {
    return this.each(function() {
      var $this = $(this)
        , data = $this.data('modal_form')
        , options = $.extend({}, $.fn.modal_single_selector.defaults, $this.data(), typeof option == 'object' && option);
      if (!data) $this.data('modal_form', (data = new ModalSingleSelector(this, options)));
      if (typeof option == 'string') data[option]();
      else if (options.show) data.show();
    });
  };

  $.fn.modal_single_selector.Constructor = ModalSingleSelector;

  $.fn.modal_single_selector.defaults = $.extend({}, $.fn.modal_form.defaults, {
  });

}(window.jQuery);

