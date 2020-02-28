/*
 * semanticcms-pagegraph - SemanticCMS component to view a graph of the current page and related pages.
 * Copyright (C) 2016  AO Industries, Inc.
 *     support@aoindustries.com
 *     7262 Bull Pen Cir
 *     Mobile, AL 36695
 *
 * This file is part of semanticcms-pagegraph.
 *
 * semanticcms-pagegraph is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * semanticcms-pagegraph is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with semanticcms-pagegraph.  If not, see <http://www.gnu.org/licenses/>.
 */

semanticcms_pagegraph = {

	/*
	 * Create the SVG label to pass in
	 * Must create in SVG namespace
	 * http://stackoverflow.com/questions/7547117/add-a-new-line-in-svg-bug-cannot-see-the-line
	 * This mimics the same way string labels get added in Dagre-D3
	 */
	createDagNode : function(text, href, nodeCssClass) {
		var svg_label = document.createElementNS('http://www.w3.org/2000/svg', 'text');
		var tspan = document.createElementNS('http://www.w3.org/2000/svg','tspan');
		tspan.setAttributeNS('http://www.w3.org/XML/1998/namespace', 'xml:space', 'preserve');
		tspan.setAttribute('dy', '1em');
		tspan.setAttribute('x', '1');
		var link = document.createElementNS('http://www.w3.org/2000/svg', 'a');
		link.setAttributeNS('http://www.w3.org/1999/xlink', 'xlink:href', href);
		//link.setAttribute('target', '_blank');
		link.textContent = text;
		tspan.appendChild(link);
		svg_label.appendChild(tspan);
		if(nodeCssClass === '') {
			return {
				label: svg_label,
				labelType: 'svg'
			};
		} else {
			return {
				label: svg_label,
				labelType: 'svg',
				class: nodeCssClass
			};
		}
	},

	createDagEdge : function(text, href) {
		var svg_edge_label = document.createElementNS('http://www.w3.org/2000/svg', 'text');
		var edge_tspan = document.createElementNS('http://www.w3.org/2000/svg','tspan');
		edge_tspan.setAttributeNS('http://www.w3.org/XML/1998/namespace', 'xml:space', 'preserve');
		edge_tspan.setAttribute('dy', '1em');
		edge_tspan.setAttribute('x', '1');
		var edge_link = document.createElementNS('http://www.w3.org/2000/svg', 'a');
		edge_link.setAttributeNS('http://www.w3.org/1999/xlink', 'xlink:href', href);
		//edge_link.setAttribute('target', '_blank');
		edge_link.textContent = text;
		edge_tspan.appendChild(edge_link);
		svg_edge_label.appendChild(edge_tspan);
		return {
			labelType: "svg",
			label: svg_edge_label
		};
	}
};
