//= require can.jquery-all
//= require controls/control
//= require models/cacheable

can.Model.Cacheable("CMS.Models.Section", {
	findAll : "GET /sections.json"
	, map_rcontrol : function(params, section) {
		return can.ajax({
			url : "/mapping/map_rcontrol"
			, data : params
			, type : "post"
			, dataType : "json"
			, success : function() {
				if(section) {
					if(params.u) {
						//unmap
						can.each(section.linked_controls, function(val, i) {
							if((params.rcontrol != null ? params.rcontrol : params.ccontrol) === val.id) {
								section.linked_controls.splice(i, 1);
							}
						});
					} else {
						//map
						section.linked_controls.push(
							new CMS.Models.ImplementingControl(
							(params.rcontrol ? CMS.Models.RegControl : CMS.Models.CompanyControl).findInCacheById(params.rcontrol).serialize()
							));
					}
					section.updated();
				}
			}
		});
	}
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
		this._super();

		var lcs = new can.Model.List();
		for(var i = 0; i < this.linked_controls.length ; i ++) {
			lcs.push(new CMS.Models.RegControl(this.linked_controls[i].serialize()));
		}
		var cs = new can.Model.List();
		for(i = 0; i < this.children.length ; i ++) {
			cs.push(new this.constructor(this.children[i].serialize()));
		}
		this.attr("linked_controls", lcs);
		this.attr("children", cs);
	}

	, map_rcontrol : function(params) {
		return this.constructor.map_rcontrol(can.extend({}, params, {section : this.id}), this);
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
			var ret = filter_out(list, function(s) { return s.parent_id == pid });
			can.$(ret).each(function() {
				this.children = treeify(list, this.id);
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
