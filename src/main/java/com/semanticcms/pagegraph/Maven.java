/*
 * semanticcms-pagegraph - SemanticCMS component to view a graph of the current page and related pages.
 * Copyright (C) 2019, 2020, 2021  AO Industries, Inc.
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

import com.aoapps.lang.Projects;
import com.aoapps.lang.util.PropertiesUtils;
import java.io.IOException;
import java.util.Properties;

abstract class Maven {

	/** Make no instances. */
	private Maven() {throw new AssertionError();}

	// Runtime Direct
	static final String d3Version;
	static final String dagreD3Version;
	// Runtime Transitive
	static final String dagreVersion;
	static final String graphlibVersion;
	static final String lodashVersion;

	static {
		try {
			Properties properties = PropertiesUtils.loadFromResource(Maven.class, "Maven.properties");
			// Runtime Direct
			d3Version = Projects.getVersion("org.webjars.npm", "d3", properties.getProperty("d3Version"));
			dagreD3Version = Projects.getVersion("org.webjars.npm", "dagre-d3", properties.getProperty("dagreD3Version"));
			// Runtime Transitive
			dagreVersion = Projects.getVersion("org.webjars.npm", "dagre", properties.getProperty("dagreVersion"));
			graphlibVersion = Projects.getVersion("org.webjars.npm", "graphlib", properties.getProperty("graphlibVersion"));
			lodashVersion = Projects.getVersion("org.webjars.npm", "lodash", properties.getProperty("lodashVersion"));
		} catch(IOException e) {
			throw new ExceptionInInitializerError(e);
		}
	}
}
