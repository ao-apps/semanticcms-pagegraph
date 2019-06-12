/*
 * semanticcms-pagegraph - SemanticCMS component to view a graph of the current page and related pages.
 * Copyright (C) 2016, 2017, 2019  AO Industries, Inc.
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
package com.semanticcms.pagegraph;

import com.semanticcms.core.renderer.html.HtmlRenderer;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

@WebListener("Registers the CSS and scripts in HtmlRenderer.")
public class PageGraphContextListener implements ServletContextListener {

	@Override
	public void contextInitialized(ServletContextEvent event) {
		HtmlRenderer htmlRenderer = HtmlRenderer.getInstance(event.getServletContext());
		htmlRenderer.addCssLink("/semanticcms-pagegraph/styles.css");
		// TODO: Get versions from a Maven.properties, with version automatically substituted from dependency
		htmlRenderer.addScript("d3js", "/webjars/d3js/5.9.1/d3.min.js");
		htmlRenderer.addScript("dagre-d3", "/webjars/dagre-d3/0.6.3/dist/dagre-d3.min.js");
		htmlRenderer.addScript("semanticcms-pagegraph", "/semanticcms-pagegraph/scripts.js");
	}

	@Override
	public void contextDestroyed(ServletContextEvent event) {
		// Do nothing
	}
}
