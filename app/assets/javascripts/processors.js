//= require can.jquery-all
//= require jquery.livequery

(function(can) {

var MutationObserver = window.MutationObserver || window.WebKitMutationObserver;

var manageObservers = function(control, type, action, selector, methodName) {
    if(!selector) {
      throw "Cannot register DOM mutation listener on the Control element";
    }
    var arr = can.getObject((type === "created" ? "_crea" : "_destruc") + "tionSelectors", control, true);

    if(action === "add") {
      arr[selector] || (arr[selector] = []);
      arr[selector].push(methodName);
    } else if(action === "remove") {
      arr[selector].splice(can.inArray(methodName, arr[selector]), 1);
    }
}

var observerfunc = function(type) {

  return function(el, event, selector, methodName, control) {

    manageObservers(control, type, "add", selector, methodName);

    if(!control._mutationObserver) {
      control._mutationObserver = new MutationObserver(function(mutations, obs) {
        for(var i = 0; i < mutations.length; i++) {
          if(mutations[i].type === "childList") {
            var nodes = mutations[i][event === "elementadded" ? "addedNodes" : "removedNodes"];
            can.each(nodes, function(node) {
              can.each(Object.keys(event === "elementadded" ? control._creationSelectors : control._destructionSelectors), function(sel) { 
                var $nodes = can.$(sel, node)
                if(can.$(node, el).is(sel)) {
                  $nodes = $nodes.add(node);
                }
                can.each($nodes, function(n) {
                  control[methodName](can.$(n, el), new can.Event(event, { target : can.$(n), currentTarget : can.$(n) }));
                });
              });
            });
          }
        }
      });

      el.each(function() {
        control._mutationObserver.observe(this, {childList : true, subtree : true});
      });
    }

    return function() {
      manageObservers(control, type, "remove", selector, methodName);
      observer.disconnect();
    }

  }
}

var eventfunc = function(type) {
  return function(el, event, selector, methodName, control) {

    manageObservers(control, type, "add", selector, methodName);

    if(type === "created" && !control._creationObserver || type === "destroyed" && !control._destructionObserver) {

      function handler(oev) {
        var ev = new can.Event(event, oev);
        var node = oev.originalEvent.target;
        if(node.nodeType === 3) return;
        var selectors = event === "elementadded" ? control._creationSelectors : control._destructionSelectors
        can.each(Object.keys(selectors), function(sel) {
          var $nodes = can.$(sel, node)
          if(can.$(node, el).is(sel)) {
            $nodes = $nodes.add(node);
          }
          can.each($nodes, function(n) {
            can.each(selectors[sel], function(method) {
              control[method](can.$(n, el), new can.Event(event, { target : can.$(n), currentTarget : can.$(n) }));
            });
          });
        });
        oev.stopPropagation();
      }

      var evtype = type === "created" ? "DOMNodeInserted" : "DOMNodeRemoved";
      control[type === "created" ? "_creationObserver" : "_destructionObserer"] = handler;
      can.bind.call(el, evtype, handler);
      return function() {
        manageObservers(control, type, "remove", selector, methodName);
        can.unbind.call(el, evtype, handler);
      }
    }
  }
}

var livequeryfunc = function(type) {

  return function(el, event, selector, methodName, control) {

    can.$(selector, el).livequery(function() {
      if(type === "created") {
        control[methodName](can.$(this), event);
      }
    }, function() {
      if(type === "destroyed") {
        control[methodName](can.$(this), event);
      }
    });

    return function() {
      el.expire();
    }

  }

}

can.extend(can.Control.processors, {
  
  // elementcreated : MutationObserver ? observerfunc("created") : livequeryfunc("created")
  // , elementdestroyed : MutationObserver ? observerfunc("destroyed") : livequeryfunc("destroyed")
  elementadded : eventfunc("created")
  , elementremoved : eventfunc("destroyed")
});

})(window.can);