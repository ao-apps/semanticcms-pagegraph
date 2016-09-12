<%--
semanticcms-pagegraph - SemanticCMS component to view a graph of the current page and related pages.
Copyright (C) 2016  AO Industries, Inc.
	support@aoindustries.com
	7262 Bull Pen Cir
	Mobile, AL 36695

This file is part of semanticcms-pagegraph.

semanticcms-pagegraph is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

semanticcms-pagegraph is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with semanticcms-pagegraph.  If not, see <http://www.gnu.org/licenses/>.
--%>
<%@ page language="java" buffer="512kb" autoFlush="true" pageEncoding="UTF-8" session="false" %>
<%@ page import="com.semanticcms.core.model.Page" %>
<%@ page import="com.semanticcms.core.model.PageRef" %>
<%@ page import="com.semanticcms.core.servlet.CapturePage" %>
<%@ page import="com.semanticcms.core.servlet.CaptureLevel" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="java.util.LinkedHashMap" %>
<%@ page import="java.util.LinkedHashSet" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>

<%@ taglib prefix="ao" uri="http://aoindustries.com/ao-taglib" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="core" uri="https://semanticcms.com/core/taglib/" %>

<%--
Adds the page DAG SVG.

For DAG, see http://cpettitt.github.io/project/dagre-d3/latest/demo/sentence-tokenization.html
             http://cpettitt.github.io/project/dagre-d3/latest/demo/tcp-state-diagram.html
             http://cpettitt.github.io/project/dagre-d3/latest/demo/hover.html
             http://jsbin.com/yiqeya/2/edit?html,css,js,output
             https://github.com/cpettitt/dagre-d3/blob/master/demo/svg-labels.html

Arguments:
	arg.page  The page that should be displayed.
	arg.view  The current view
--%>
<c:set var="page" value="${arg.page}" />
<c:set var="view" value="${arg.view}" />

<%-- Build the DAG for display in JavaScript below --%>
<%!
	private static void addAllParents(
		ServletContext servletContext,
		HttpServletRequest request,
		HttpServletResponse response,
		Page page,
		Map<Page,Set<Page>> dag,
		Set<PageRef> visited
	) throws ServletException, IOException {
		PageRef pageRef = page.getPageRef();
		if(visited.add(pageRef)) {
			// Default to empty children, to make sure leaf pages are in the dag
			if(!dag.containsKey(page)) dag.put(page, new LinkedHashSet<Page>());
			for(PageRef parentRef : page.getParentPages()) {
				// Skip missing books
				if(parentRef.getBook() != null) {
					Page parent = CapturePage.capturePage(
						servletContext,
						request,
						response,
						parentRef,
						CaptureLevel.BODY
					);
					Set<Page> siblings = dag.get(parent);
					if(siblings == null) {
						siblings = new LinkedHashSet<Page>();
						dag.put(parent, siblings);
					}
					if(!siblings.add(page)) throw new AssertionError("Duplicate sibling: " + pageRef);
					addAllParents(
						servletContext,
						request,
						response,
						parent,
						dag,
						visited
					);
				}
			}
		}
	}

	private static Map<Page,Set<Page>> createDag(
		ServletContext servletContext,
		HttpServletRequest request,
		HttpServletResponse response,
		Page page
	) throws ServletException, IOException {
		Map<Page,Set<Page>> dag = new LinkedHashMap<Page,Set<Page>>();
		Set<PageRef> visited = new HashSet<PageRef>();
		// Add children
		boolean hasChild = false;
		for(PageRef childRef : page.getChildPages()) {
			// Skip missing books
			if(childRef.getBook() != null) {
				hasChild = true;
				Page child = CapturePage.capturePage(
					servletContext,
					request,
					response,
					childRef,
					CaptureLevel.BODY
				);
				addAllParents(
					servletContext,
					request,
					response,
					child,
					dag,
					visited
				);
			}
		}
		if(!hasChild) {
			// Add all siblings when have no children
			for(PageRef parentRef : page.getParentPages()) {
				// Skip missing books
				if(parentRef.getBook() != null) {
					Page parent = CapturePage.capturePage(
						servletContext,
						request,
						response,
						parentRef,
						CaptureLevel.BODY
					);
					for(PageRef siblingRef : parent.getChildPages()) {
						// Skip missing books
						if(siblingRef.getBook() != null) {
							Page sibling = CapturePage.capturePage(
								servletContext,
								request,
								response,
								siblingRef,
								CaptureLevel.BODY
							);
							addAllParents(
								servletContext,
								request,
								response,
								sibling,
								dag,
								visited
							);
						}
					}
				}
			}
		}
		// Always add self, in case of non recriprocal child-parent relationship
		addAllParents(
			servletContext,
			request,
			response,
			page,
			dag,
			visited
		);
		return dag;
	}
%>
<%
	// Build DAG
	Map<Page,Set<Page>> dag = createDag(
		pageContext.getServletContext(),
		(HttpServletRequest)pageContext.getRequest(),
		(HttpServletResponse)pageContext.getResponse(),
		(Page)pageContext.getAttribute("page")
	);

	// Assign integer IDs to pages
	Map<Page,Integer> dagIndexes = new HashMap<Page,Integer>(dag.size()*4/3 + 1);
	int index = 0;
	for(Map.Entry<Page,Set<Page>> entry : dag.entrySet()) {
		dagIndexes.put(entry.getKey(), index++);
	}

	pageContext.setAttribute("dag", dag);
	pageContext.setAttribute("dagIndexes", dagIndexes);

	// To reduce the number of passes through time-consuming operations, resulting classes are stored here
	pageContext.setAttribute("classByPage", new HashMap<Page,String>());
%>
<nav id="semanticcms-pagegraph-dag">
	<h1 id="semanticcms-pagegraph-header">Page Tree<%-- Yeah, I know it's a DAG --%></h1>
	<%--
		Mobile version of Chrome does not process contents of noscript enough to get access to the href,
		so we have to include the elements here then immediately hide them when scripting is enabled.
		This is, in effect, an emulation of <noscript>
	--%>
	<div id="semanticcms-pagegraph-noscript">
		<%-- User experience for when JavaScript is disabled --%>
		<%-- TODO: Can parts of this be legit noscript? --%>
		<%-- Note: The scripts below pickup the URLs from these links, this is so rewritten links are used after export --%>
		<%-- TODO: Better user experience, this is just enough for the scripts below --%>
		<%-- TODO: SEO aspects: remove nofollow here to assist in page discovery? --%>
		<%-- TODO: SEO aspects: maybe remove nofollow from links to direct parents and direct children --%>
		<ul>
			<c:forEach var="dagEntry" items="${dag}">
				<c:set var="dagPage" value="${dagEntry.key}" />
				<c:choose>
					<c:when test="${dagPage == page}">
						<c:set var="nodeCssClass" value="semanticcms-pagegraph-this-page" />
					</c:when>
					<c:when test="${!core:isViewApplicable(view, dagPage)}">
						<c:set var="nodeCssClass" value="semanticcms-pagegraph-page-disabled" />
					</c:when>
					<c:otherwise>
						<c:set var="nodeCssClass" value="" />
					</c:otherwise>
				</c:choose>
				<%-- Doesn't work, could be due to object as key, movin' on: <c:set target="${classByPage}" property="${dagPage}" value="${nodeCssClass}" />--%>
				<%
					// Life is too short to be perfect, doing what works:
					Map testMap = (Map)pageContext.getAttribute("classByPage");
					testMap.put(pageContext.getAttribute("dagPage"), pageContext.getAttribute("nodeCssClass"));
				%>
				<c:if test="${nodeCssClass != 'semanticcms-pagegraph-this-page' && nodeCssClass != 'semanticcms-pagegraph-page-disabled'}">
					<li><ao:a
						id="semanticcms-pagegraph-link-${dagIndexes[dagPage]}"
						rel="nofollow"
						href="${dagPage.pageRef.servletPath}"
						param.view="${view.isDefault() ? null : view.name}"
					>
						<ao:params values="${core:getViewLinkParams(view, dagPage)}" />
						<ao:out value="${dagPage.title}" />
					</ao:a></li><%-- shortTitle once relationship clear --%>
				</c:if>
			</c:forEach>
		</ul>
	</div>
	<ao:script>
		// Emulate noscript
		document.getElementById("semanticcms-pagegraph-noscript").style.display = "none";

		try {
			// Create a new directed graph
			var g = new dagreD3.graphlib.Graph()
				.setGraph({})
				.setDefaultEdgeLabel(function() { return {}; });

			<%--
			g.setNode(0,  semanticcms_pagegraph.createDagNode('IE Capable link', 'http://google.com/'));
			g.setNode(1,  { label: "A" });
			g.setNode(2,  { label: "B" });
			--%>
			<c:forEach var="dagEntry" items="${dag}">
				<c:set var="dagPage" value="${dagEntry.key}" />
				<c:set var="nodeCssClass" value="${classByPage[dagPage]}" />
				<c:choose>
					<%-- Non-clickable nodes --%>
					<c:when test="${nodeCssClass == 'semanticcms-pagegraph-this-page' || nodeCssClass == 'semanticcms-pagegraph-page-disabled'}">
						g.setNode(
							parseInt(<ao:out value="${dagIndexes[dagPage]}" />),
							{
								label: <ao:out value="${dagPage.shortTitle}" />,
								class: <ao:out value="${nodeCssClass}" />
							}
						);
					</c:when>
					<%-- Clickable nodes --%>
					<c:otherwise>
						g.setNode(
							parseInt(<ao:out value="${dagIndexes[dagPage]}" />),
							semanticcms_pagegraph.createDagNode(
								<ao:out value="${dagPage.shortTitle}" />,
								document.getElementById('semanticcms-pagegraph-link-' + <ao:out value="${dagIndexes[dagPage]}" />).getAttribute('href'),
								<ao:out value="${nodeCssClass}" />
							)
						);
					</c:otherwise>
				</c:choose>
			</c:forEach>

			// Round the corners of the nodes
			g.nodes().forEach(function(v) {
				var node = g.node(v);
				node.rx = node.ry = 5;
			});

			// Set up edges, no special attributes.
			<%--
			g.setEdge(0, 1, semanticcms_pagegraph.createDagEdge('IE Capable Edge link 2', 'http://google.com/'));
			g.setEdge(0, 2);
			g.setEdge(1, 2);
			--%>
			<c:forEach var="dagEntry" items="${dag}">
				<c:set var="dagParentPage" value="${dagEntry.key}" />
				<c:forEach var="dagChildPage" items="${dagEntry.value}">
					g.setEdge(
						parseInt(<ao:out value="${dagIndexes[dagParentPage]}" />),
						parseInt(<ao:out value="${dagIndexes[dagChildPage]}" />)
					);
				</c:forEach>
			</c:forEach>

			// See https://vaadin.com/forum#!/thread/11835698
			var svg = d3.select(document.getElementById("semanticcms-pagegraph-dag")).append("svg"), // .attr("width", 480).attr("height", 300),
				svgGroup = svg.append("g");

			// Create the renderer
			var render = new dagreD3.render();

			// Run the renderer. This is what draws the final graph.
			render(svgGroup, g);

			// Center the graph
			// svgGroup.attr('transform', 'translate(20, 20)');
			// svg.attr('width', g.graph().width + 40);
			// svg.attr('height', g.graph().height + 40);

			// Scale and center the graph
			var scale = 0.8;
			svgGroup.attr('transform', 'translate(20, 20) scale(' + scale + ')');
			svg.attr('width', g.graph().width * scale + 40);
			svg.attr('height', g.graph().height * scale + 40);

			// Enable zoom/pan
			// https://github.com/cpettitt/dagre-d3/issues/27
			// svg.call(d3.behavior.zoom().on("zoom", function() {
			// 	var ev = d3.event;
			// 	svg.select("g")
			// 	   .attr("transform", "translate(" + ev.translate + ") scale(" + ev.scale + ")");
			// }));
		} catch(e) {
			window.alert("Exception in pagegraph: " + e.message);
		}
	</ao:script>
</nav>