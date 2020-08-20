/*
 * semanticcms-pagegraph - SemanticCMS component to view a graph of the current page and related pages.
 * Copyright (C) 2019, 2020  AO Industries, Inc.
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

import com.aoindustries.lang.Projects;
import com.aoindustries.util.PropertiesUtils;
import java.io.IOException;
import java.util.Properties;

class Maven {

	static final String d3jsVersion;
	static final String dagreD3Version;

	static {
		try {
			Properties properties = PropertiesUtils.loadFromResource(Maven.class, "Maven.properties");
			d3jsVersion = Projects.getVersion("org.webjars", "d3js", properties.getProperty("d3jsVersion"));
			dagreD3Version = Projects.getVersion("org.webjars.npm", "dagre-d3", properties.getProperty("dagreD3Version"));
		} catch(IOException e) {
			throw new ExceptionInInitializerError(e);
		}
	}

	private Maven() {}
}
