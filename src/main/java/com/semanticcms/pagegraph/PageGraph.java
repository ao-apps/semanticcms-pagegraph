/*
 * semanticcms-pagegraph - SemanticCMS component to view a graph of the current page and related pages.
 * Copyright (C) 2016, 2017, 2019, 2020, 2021, 2022  AO Industries, Inc.
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
 * along with semanticcms-pagegraph.  If not, see <https://www.gnu.org/licenses/>.
 */

package com.semanticcms.pagegraph;

import com.aoapps.net.URIEncoder;
import com.aoapps.web.resources.registry.Group;
import com.aoapps.web.resources.registry.Style;
import com.aoapps.web.resources.servlet.RegistryEE;
import com.semanticcms.core.servlet.SemanticCMS;
import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

@WebListener("Registers the CSS and scripts in RegistryEE and SemanticCMS.")
public class PageGraph implements ServletContextListener {

  public static final Group.Name RESOURCE_GROUP = new Group.Name("semanticcms-pagegraph");

  // TODO: Change to Group.Name once we have group-level ordering
  public static final Style SEMANTICCMS_PAGEGRAPH = new Style("/semanticcms-pagegraph/semanticcms-pagegraph.css");
  public static final Style SEMANTICCMS_PAGEGRAPH_PRINT = Style.builder()
    .uri("/semanticcms-pagegraph/semanticcms-pagegraph-print.css")
    .media("print")
    .build();

  @Override
  public void contextInitialized(ServletContextEvent event) {
    ServletContext servletContext = event.getServletContext();

    // Add our CSS files
    RegistryEE.Application.get(servletContext)
      .activate(RESOURCE_GROUP) // TODO: Activate as-needed
      .getGroup(RESOURCE_GROUP)
      .styles
      .add(
        SEMANTICCMS_PAGEGRAPH,
        SEMANTICCMS_PAGEGRAPH_PRINT
      );

    SemanticCMS semanticCMS = SemanticCMS.getInstance(servletContext);
    semanticCMS.addScript("d3", "/webjars/d3/" + URIEncoder.encodeURIComponent(Maven.d3Version) + "/dist/d3.min.js");
    semanticCMS.addScript("lodash", "/webjars/lodash/" + URIEncoder.encodeURIComponent(Maven.lodashVersion) + "/lodash.min.js");
    semanticCMS.addScript("graphlib", "/webjars/graphlib/" + URIEncoder.encodeURIComponent(Maven.graphlibVersion) + "/dist/graphlib.min.js");
    semanticCMS.addScript("dagre", "/webjars/dagre/" + URIEncoder.encodeURIComponent(Maven.dagreVersion) + "/dist/dagre.min.js");
    semanticCMS.addScript("dagre-d3", "/webjars/dagre-d3/" + URIEncoder.encodeURIComponent(Maven.dagreD3Version) + "/dist/dagre-d3.min.js");
    semanticCMS.addScript("semanticcms-pagegraph", "/semanticcms-pagegraph/semanticcms-pagegraph.js");
  }

  @Override
  public void contextDestroyed(ServletContextEvent event) {
    // Do nothing
  }
}
