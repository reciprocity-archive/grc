//= require can.jquery-all

can.Model("can.Model.Cacheable", {

  init : function() {
    this.bind("created", function(ev, new_obj) {
      if(new_obj.id) {
        can.getObject("cache", new_obj.constructor, true)[new_obj.id] = new_obj;
      }
    });
    this.bind("destroyed", function(ev, old_obj) {
      delete can.getObject("cache", old_obj.constructor, true)[old_obj.id];
    });
  }

  , findInCacheById : function(id) {
    return can.getObject("cache", this, true)[id];
  }  

  , newInstance : function(args) {
    var cache = can.getObject("cache", this, true);
    if(args && args.id && cache[args.id]) {
      //cache[args.id].attr(args, false); //CanJS has bugs in recursive merging 
                                          // (merging -- adding properties from an object without removing existing ones 
                                          //  -- doesn't work in nested objects).  So we're just going to not merge properties.
      return cache[args.id];
    } else {
      return can.Model.Cacheable.prototype.__proto__.constructor.newInstance.apply(this, arguments);
    }
  }

}, {
  init : function() {
    var obj_name = this.constructor.root_object;
    if(typeof obj_name !== "undefined" && this[obj_name]) {
        for(var i in this[obj_name].serialize()) {
          if(this[obj_name].hasOwnProperty(i)) {
            this.attr(i, this[obj_name][i]);
          }
        }
        this.removeAttr(obj_name);
    }

    var cache = can.getObject("cache", this.constructor, true);
    cache[this.id] = this;
  }
  , addElementToChildList : function(attrName, new_element) {
    this[attrName].push(new_element);
    this._triggerChange(attrName, "set", this[attrName], this[attrName].slice(0, this[attrName].length - 1));
  }
  , removeElementFromChildList : function(attrName, old_element, all_instances) {
    for(var i = this[attrName].length - 1 ; i >= 0; i--) {
      if(this[attrName][i]===old_element) {
        this[attrName].splice(i, 1);
        if(!all_instances) break;
      }
    }
    this._triggerChange(attrName, "set", this[attrName], this[attrName].slice(0, this[attrName].length - 1));
  }
});