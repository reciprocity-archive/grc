can.Model("CMS.Models.Section", {
	findAll : "GET /sections.json"
}, {

	init : function() {

			if(this.section) {
				var attrs = this.section._attrs();
				for(var i in attrs) {
					if(attrs.hasOwnProperty(i)) {
						this.attr(i, this.section[i]);
					}
				}
				this.removeAttr("section");
			}

			var lcs = new can.Model.List();
			for(var i = 0; i < this.linked_controls.length ; i ++) {
				lcs.push(new CMS.Models.RegControl(this.linked_controls[i]._attrs()));
			}
			this.attr("linked_controls", lcs);

	}

});

CMS.Models.Section("CMS.Models.SectionSlug", {
	findAll : function(params) {
		function filter_out(original, predicate) {
			var target = [];
			for(var i = original.length - 1; i >= 0; i--) {
				if(predicate(original[i])) {
					target.unshift(original.splice(i, 1)[0]);
				}
			}
			return target;
		}

		function treeify(list, pid) {
			var ret = filter_out(list, function(s) { return s.section.parent_id == pid });
			can.$(ret).each(function() {
				this.section.children = treeify(list, this.section.id);
			});
			return ret;
		}

		return can.ajax({ 
			url : "/programs/" + (params.id || false) + "/sections.json"
			, type : "get"
			, dataType : "json"
			, data : params
			}).then(
				function(list, xhr) {
					can.$(list).each(function(i, s) {
						can.extend(s, s.section);
						delete s.section;
					});
					var roots = treeify(list); //empties the list
					for(var i = 0; i < roots.length; i++)
						list.push(roots[i]);
				});
	}
}, {});
