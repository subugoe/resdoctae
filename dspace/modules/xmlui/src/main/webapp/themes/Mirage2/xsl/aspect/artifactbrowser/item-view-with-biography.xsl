<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->

<!--
    Rendering specific to the item display page.

    Author: art.lowel at atmire.com
    Author: lieven.droogmans at atmire.com
    Author: ben at atmire.com
    Author: Alexey Maslov

-->

<xsl:stylesheet
        xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
        xmlns:dri="http://di.tamu.edu/DRI/1.0/"
        xmlns:mets="http://www.loc.gov/METS/"
        xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
        xmlns:xlink="http://www.w3.org/TR/xlink/"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
        xmlns:atom="http://www.w3.org/2005/Atom"
        xmlns:ore="http://www.openarchives.org/ore/terms/"
        xmlns:oreatom="http://www.openarchives.org/ore/atom/"
        xmlns="http://www.w3.org/1999/xhtml"
        xmlns:xalan="http://xml.apache.org/xalan"
        xmlns:encoder="xalan://java.net.URLEncoder"
        xmlns:util="org.dspace.app.xmlui.utils.XSLUtils"
        xmlns:jstring="java.lang.String"
        xmlns:rights="http://cosimo.stanford.edu/sdr/metsrights/"
        xmlns:confman="org.dspace.core.ConfigurationManager"
        exclude-result-prefixes="xalan encoder i18n dri mets dim xlink xsl util jstring rights confman">

    <xsl:output indent="yes"/>

    <!-- global variables -->
    <xsl:variable name="portalURL">http://adw-digital.sub.uni-goettingen.de/</xsl:variable>
    <xsl:variable name="baseURL">http://rep.adw-goe.de/</xsl:variable>
    <xsl:variable name="googleViewURL">http://docs.google.com/viewer?url=</xsl:variable>
    <xsl:variable name="dfgViewURL">http://dfg-viewer.de/demo/viewer/?set[mets]=</xsl:variable>
    <xsl:variable name="multivioViewURL">http://demo.multivio.org/client/#get&amp;url=</xsl:variable>
    <xsl:variable name="gsDBURL">http://personendatenbank.germania-sacra.de/</xsl:variable>
    <xsl:variable name="gsDBSearch">persons/index</xsl:variable>
    <xsl:variable name="gsDBSearchParams">?query[3][field]=fundstelle.bandnummer&amp;query[3][operator]=like&amp;query[3][value]=</xsl:variable>
    <xsl:variable name="gsConventDBURL">http://klosterdatenbank.germania-sacra.de/gsn/</xsl:variable>

    <xsl:template name="itemSummaryView-DIM">
    <!-- Generate the info about the item from the metadata section -->
        <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                             mode="itemSummaryView-DIM"/>

        <xsl:copy-of select="$SFXLink" />

        <!-- Generate the Creative Commons license information from the file section (DSpace deposit license hidden by default)-->
        <xsl:if test="./mets:fileSec/mets:fileGrp[@USE='CC-LICENSE' or @USE='LICENSE']">
            <div class="license-info table">
                <p>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.license-text</i18n:text>
                </p>
                <ul class="list-unstyled">
                    <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CC-LICENSE' or @USE='LICENSE']" mode="simple"/>
                </ul>
            </div>
        </xsl:if>


    </xsl:template>

    <!-- An item rendered in the detailView pattern, the "full item record" view of a DSpace item in Manakin. -->
    <xsl:template name="itemDetailView-DIM">
        <!-- Output all of the metadata about the item from the metadata section -->
        <xsl:apply-templates select="mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                             mode="itemDetailView-DIM"/>

        <!-- Generate the bitstream information from the file section -->
        <xsl:choose>
            <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">
                <h3><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text></h3>
                <div class="file-list">
                    <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE' or @USE='CC-LICENSE']">
                        <xsl:with-param name="context" select="."/>
                        <xsl:with-param name="primaryBitstream" select="./mets:structMap[@TYPE='LOGICAL']/mets:div[@TYPE='DSpace Item']/mets:fptr/@FILEID"/>
                    </xsl:apply-templates>
                </div>
            </xsl:when>
            <!-- Special case for handling ORE resource maps stored as DSpace bitstreams -->
            <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='ORE']">
                <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='ORE']" mode="itemDetailView-DIM" />
            </xsl:when>
            <xsl:otherwise>
                <h2><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text></h2>
                <table class="ds-table file-list">
                    <tr class="ds-table-header-row">
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-file</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-size</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-format</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-view</i18n:text></th>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <p><i18n:text>xmlui.dri2xhtml.METS-1.0.item-no-files</i18n:text></p>
                        </td>
                    </tr>
                </table>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>


    <xsl:template match="dim:dim" mode="itemSummaryView-DIM">
    <!-- render special coll with biographies different -->	    
    <xsl:choose>
    <xsl:when test="//dim:field[@element='type']='biography'">
        <div class="row">
            <div class="col-xs-12">
		    <div class="item-summary-view-metadata">
			<h1 class="first-page-header">
				<xsl:value-of select="dim:field[@element='title'][not(@qualifier)]/node()"/>
				<xsl:for-each select="//dim:field[@qualifier='biographykey']">
					<span id="key" class="small"><xsl:value-of select="concat(' (', . ,')')"/></span>
				</xsl:for-each>
		    	</h1>	   
			<xsl:if test="//dim:field[contains(@qualifier,'birthday')]"> 
				<span class="subtitle bigger">
					<xsl:for-each select="//dim:field[@element='description' and @qualifier='birthday']">
						<xsl:value-of select="concat('&#42; ', translate(.,'-', '.'))"/>
						<xsl:if test="//dim:field[@qualifier='birthplace']"><xsl:value-of select="concat(' ', //dim:field[@qualifier='birthplace'])"/></xsl:if>
					</xsl:for-each>
					<xsl:for-each select="//dim:field[@element='description' and @qualifier='deathday']">
						<xsl:value-of select="concat(';  &#8224; ', translate(.,'-', '.'))"/>
						<xsl:if test="//dim:field[@qualifier='birthplace']"><xsl:value-of select="concat(' ', //dim:field[@qualifier='deathplace'])"/></xsl:if>
                                        </xsl:for-each>
				</span>
				<br /><br />
			</xsl:if>
			<xsl:if test="dim:field[@element='relation' and @qualifier='bibliography']">
				<div class="simple-item-view-other">
					<span class="bold">Biographies: </span>
					<xsl:value-of select="dim:field[@element='relation' and @qualifier='bibliography']" disable-output-escaping="yes"/>
				</div>
			</xsl:if>
			<xsl:if test="dim:field[@element='description' and @qualifier='biography']">
                                <div class="simple-item-view-other">
                                        <span class="bold">Life: </span>
                                        <xsl:value-of select="dim:field[@element='description' and @qualifier='biography']" disable-output-escaping="yes"/>
                                </div>
			</xsl:if>
			<xsl:for-each select="//dim:field[@qualifier='wikidata']">
				<div class="simple-item-view-other">
				<img class="wikidata-logo" alt="wikidata logo" src="https://www.wikidata.org/static/images/project-logos/wikidatawiki.png"></img> 
				<a>
					<xsl:attribute name="href"><xsl:value-of select="."/></xsl:attribute>
					<xsl:value-of select="."/>
				</a>
				</div>
			</xsl:for-each>
		</div>
		
		<div class="separate">

			    <xsl:call-template name="itemSummaryView-show-full"/>
			    <xsl:call-template name="itemSummaryView-collections"/>
		</div>
	    </div>

        </div>
      </xsl:when>
      <xsl:otherwise>
        <div class="row">
            <div class="col-xs-12">
                <div class="item-summary-view-metadata">
                    <xsl:call-template name="itemSummaryView-DIM-title"/>
                    <xsl:call-template name="itemSummaryView-DIM-fields"/>
                </div>
            </div>

        </div>
        <div class="row files">
            <div class="col-xs-12 col-sm-3 col-md-3 col-lg-3">
                <xsl:call-template name="itemSummaryView-DIM-thumbnail"/>
            </div>
            <div class="col-xs-12 col-sm-9 col-md-9 col-lg-9">
                <xsl:call-template name="itemSummaryView-DIM-file-section"/>
            </div>
        </div>
        <div class="row">
            <div class="col-xs-12">
                <xsl:call-template name="parts"/>
                <xsl:if test="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/dim:field[@element='description' and @qualifier='embargoed']">
                    <div class="embargo-info">
                        <p><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-embargoed1</i18n:text><xsl:value-of select="translate(./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/dim:field[@element='description' and @qualifier='embargoed'], '-', '.')"/><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-embargoed2</i18n:text></p>
                    </div>
                </xsl:if>

                <xsl:if test="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/dim:field[@element='description' and @qualifier='abstract']">
                    <div class="item-summary-view-metadata">

                        <span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-abstract</i18n:text>: </span>
                        <br />
                        <span>
                            <xsl:value-of select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/dim:field[@element='description' and @qualifier='abstract']" disable-output-escaping="yes"/>

                        </span>
                    </div>
                </xsl:if>

                <hr />
                <div id="socialmedia">
                    <i18n:text>xmlui.socialmedia.share</i18n:text>
                    <ul class="share-buttons">
                        <li><a>
                            <xsl:attribute name="href"><xsl:value-of select="concat('http://www.mendeley.com/import/?url=', //dim:field[@element='identifier'][@qualifier='uri']) "/></xsl:attribute>
                            <img src="{concat($theme-path,'/images/mendeley-16.png')}" title="Mendeley"> </img>
                        </a></li>
                        <li><a>
                            <xsl:attribute name="href"><xsl:value-of select="concat('http://www.linkedin.com/shareArticle?url=', //dim:field[@element='identifier'][@qualifier='uri'], '&amp;title=', //dim:field[@element='title' and not(@qualifier)]) "/></xsl:attribute>
                            <img src="{concat($theme-path,'/images/linkedin-16.png')}" title="LinkedIn"> </img>
                        </a></li>
                        <li><a>
                            <xsl:attribute name="href"><xsl:value-of select="concat('http://www.bibsonomy.org/ShowBookmarkEntry?&amp;c=b&amp;jump=yes&amp;url=', //dim:field[@element='identifier'][@qualifier='uri'], '&amp;description=', //dim:field[@element='title' and not(@qualifier)]) "/></xsl:attribute>
                            <img src="{concat($theme-path,'/images/bibsonomy-16.png')}" title="Bibsonomy"> </img>
                        </a></li>
                        <li><a>
                            <xsl:attribute name="href"><xsl:value-of select="concat('http://twitter.com/intent/tweet?text=', //dim:field[@element='title' and not(@qualifier)], '&amp;url=', //dim:field[@element='identifier' and @qualifier='uri']) "/></xsl:attribute>
                            <img src="{concat($theme-path,'/images/twitter-16.png')}" title="Twitter"> </img>
                        </a></li>
                    </ul>
                </div>
		<hr />
                <xsl:call-template name="itemSummaryView-collections"/>
            </div>
        </div>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-title">
	 <xsl:choose>
            <xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) &gt; 1">
                <!-- Prepend volume in title -->
                <h1 class="first-page-header">
                    <xsl:value-of select="dim:field[@element='title'][not(@qualifier)][1]/node()"/>
                </h1>
                <div class="simple-item-view-other">
			<!-- <span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-title</i18n:text>:</span> -->
                    <span>
                        <xsl:for-each select="dim:field[@element='title'][not(@qualifier)]">
                            <xsl:value-of select="./node()"/>
                            <xsl:if test="count(following-sibling::dim:field[@element='title'][not(@qualifier)]) != 0">
                                <xsl:text>; </xsl:text>
                                <br/>
                            </xsl:if>
                        </xsl:for-each>
                    </span>
                </div>
	</xsl:when>
	<xsl:otherwise>
		<h1 class="first-page-header">
                    <xsl:value-of select="dim:field[@element='title'][not(@qualifier)]/node()"/>
                </h1>
	</xsl:otherwise>
        </xsl:choose>
	<xsl:if test="dim:field[@element='title'][@qualifier='alternative']">
		<div class="simple-item-view-authors item-page-field-wrapper">
	            <span class="subtitle"> <xsl:value-of select="dim:field[@element='title'][@qualifier='alternative']"/></span>
		</div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-thumbnail">
        <div class="thumbnail">
            <xsl:choose>
                <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']">
                    <xsl:variable name="src">
                        <xsl:choose>
                            <xsl:when test="/mets:METS/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file[@GROUPID=../../mets:fileGrp[@USE='CONTENT']/mets:file[@GROUPID=../../mets:fileGrp[@USE='THUMBNAIL']/mets:file/@GROUPID][1]/@GROUPID]">
                                <xsl:value-of
                                        select="/mets:METS/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file[@GROUPID=../../mets:fileGrp[@USE='CONTENT']/mets:file[@GROUPID=../../mets:fileGrp[@USE='THUMBNAIL']/mets:file/@GROUPID][1]/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                        select="//mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <!-- Checking if Thumbnail is restricted and if so, show a restricted image -->
                    <xsl:choose>
                        <xsl:when test="contains($src,'isAllowed=n')"/>
                        <xsl:otherwise>
                            <img class="img-thumbnail" alt="Thumbnail">
                                <xsl:attribute name="src">
                                    <xsl:value-of select="$src"/>
                                </xsl:attribute>
                            </img>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <img class="img-thumbnail" alt="Thumbnail">
                        <xsl:attribute name="data-src">
                            <xsl:text>holder.js/100%x</xsl:text>
                            <xsl:value-of select="$thumbnail.maxheight"/>
                            <xsl:text>/text:No Thumbnail</xsl:text>
                        </xsl:attribute>
                    </img>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-fields">
	<xsl:call-template name="itemSummaryView-DIM-authors"/>
        <!-- <xsl:call-template name="itemSummaryView-DIM-ispartof"/> -->
        <xsl:call-template name="itemSummaryView-DIM-edition"/>
	<xsl:call-template name="itemSummaryView-DIM-date"/>
	<xsl:call-template name="itemSummaryView-DIM-journalarticle"/>
        <xsl:call-template name="itemSummaryView-DIM-publisher"/>
	<xsl:call-template name="itemSummaryView-DIM-extent"/>
	<xsl:call-template name="itemSummaryView-DIM-doi"/>
        <xsl:call-template name="itemSummaryView-DIM-isbn"/>
        <xsl:call-template name="itemSummaryView-DIM-toc"/>
	<xsl:call-template name="itemSummaryView-DIM-series"/>
	<xsl:call-template name="itemSummaryView-DIM-printedition"/>

	<!-- <xsl:call-template name="itemSummaryView-DIM-abstract"/> -->
	<xsl:call-template name="itemSummaryView-DIM-URI"/>
	<xsl:call-template name="itemSummaryView-show-full"/>
	<!-- <xsl:call-template name="itemSummaryView-DIM-biblio-export"/> -->


    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-abstract">
        <xsl:if test="dim:field[@element='description' and @qualifier='abstract']">
            <div class="simple-item-view-description item-page-field-wrapper table">
                <span  class="bold">
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-content</i18n:text>:
                </span>
                <div>
                    <xsl:for-each select="dim:field[@element='description' and @qualifier='abstract']">
                        <xsl:value-of select="." disable-output-escaping="yes"/>
                        <xsl:if test="count(following-sibling::dim:field[@element='description' and @qualifier='abstract']) != 0">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='description' and @qualifier='abstract']) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-authors">
        <xsl:if test="not(//dim:field[@element='description'][@qualifier='view'])">
            <xsl:if test="dim:field[@element='contributor' and descendant::text()]">
                <div class="simple-item-view-authors item-page-field-wrapper">
                    <xsl:choose>
                        <xsl:when test="dim:field[@element='contributor' and @qualifier='author']">
                            <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                                <xsl:call-template name="itemSummaryView-DIM-authors-entry" />
                                <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='contributor' and @qualifier='editor']">
                            <xsl:for-each select="dim:field[@element='contributor'][@qualifier='editor']">
                                <xsl:call-template name="itemSummaryView-DIM-editors-entry" />
                                <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='editor']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                            <i18n:text>xmlui.item.editor</i18n:text>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='contributor']">
                            <xsl:for-each select="dim:field[@element='contributor']">
                                <xsl:call-template name="itemSummaryView-DIM-authors-entry" />
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                        </xsl:otherwise>
			</xsl:choose>
			<xsl:call-template name="itemSummaryView-DIM-ispartof"/>
                </div>
            </xsl:if>
        </xsl:if>
    </xsl:template>


    <xsl:template name="itemSummaryView-DIM-authors-entry">
        <span>
            <xsl:if test="@authority">
                <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:copy-of select="node()"/>
        </span>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-editors-entry">
        <span>
            <xsl:if test="@authority">
                <xsl:attribute name="class"><xsl:text>ds-dc_contributor_editor-authority</xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:copy-of select="node()"/>
        </span>
    </xsl:template>

    <!-- dc.edition row -->
    <xsl:template name="itemSummaryView-DIM-edition">
        <xsl:if test="dim:field[@element='description' and @qualifier='edition']">
            <div class="simple-item-view-other">
                <span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-edition</i18n:text>: </span>
                <span>
                    <xsl:for-each select="dim:field[@qualifier='edition']">
                        <xsl:value-of select="."/>
                    </xsl:for-each>
                </span>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-series">
	    <xsl:if test="dim:field[@element='relation' and @qualifier='ispartofseries' and descendant::text()]">    
		    <div class="simple-item-view-other">
                        <span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-series</i18n:text>: </span>
        <xsl:for-each select="dim:field[@element='relation' and @qualifier='ispartofseries' and descendant::text()]">
		<xsl:value-of select="."/>
		<xsl:if test="position() != last()">
			<xsl:text>, </xsl:text>
		</xsl:if>
	</xsl:for-each>
		</div>
    </xsl:if>
    </xsl:template>

    <!-- special GS row: link to GS search -->
    <xsl:template name="itemSummaryView-DIM-gs-reg">
        <xsl:if test="dim:field[@element='identifier' and @qualifier='gsReg' and descendant::text()]">
            <div class="simple-item-view-other">
                <span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-persDB</i18n:text>: </span>
                <a href="{concat($gsDBURL, $gsDBSearch, $gsDBSearchParams, translate(dim:field[@element='identifier' and @qualifier='gsReg'], ' ', '+'))}" target="_blank"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-persDB-long</i18n:text>             </a>
            </div>
        </xsl:if>
    </xsl:template>

    <!-- special GS row: link to GS Kloster DB -->
    <xsl:template name="itemSummaryView-DIM-convent">
        <xsl:if test="dim:field[@element='relation' and @qualifier='convent'] and descendant::text()">
            <div class="simple-item-view-other">
                <span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-klosterDB</i18n:text>: </span>
                <xsl:for-each select="dim:field[@element='relation' and @qualifier='convent']">
                    <a href="{concat($gsConventDBURL, substring-after(., ':'))}" target="_blank"><xsl:value-of select="substring-before(., ':')"/></a>
                    <xsl:if test="position() != last()">
                        <xsl:text>; </xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-biblio-export">
        <div class="biblio-export">
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="concat('/bibtex/handle/', substring-after(//dim:field[@element='identifier' and @qualifier='uri'],'hdl.handle.net/'))"/>
                </xsl:attribute>
                <i18n:text>xmlui.bibtex.export</i18n:text>
            </a>
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-ispartof">
        <xsl:if test="dim:field[@element='relation' and @qualifier='ispartof' and descendant::text()]">
            <div class="ispartof">
		    <!-- <span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-ispartof</i18n:text>:</span> -->
                    <xsl:for-each select="dim:field[@element='relation' and @qualifier='ispartof']">
                        <xsl:choose>
                            <xsl:when test="starts-with(., 'http')">
                                <xsl:variable name="handle"><xsl:value-of select="substring-after(., 'hdl.handle.net')"/></xsl:variable>
                                <xsl:variable name="metsfile"><xsl:value-of select="concat('cocoon://metadata/handle',$handle, '/mets.xml')"/></xsl:variable>
                                <a>
                                    <xsl:attribute name="href"><xsl:value-of select="."/></xsl:attribute>
                                    <xsl:value-of select="document($metsfile)//dim:field[@element='title']"/>
                                </a>
                            </xsl:when>
                            <xsl:otherwise>

                                <xsl:value-of select="./node()"/>
                            </xsl:otherwise>
                        </xsl:choose>
		    </xsl:for-each>
		    <xsl:if test="//dim:field[@element='bibliographicCitation' and @qualifier='volume']">
			    <xsl:value-of select="concat(', ', //dim:field[@element='bibliographicCitation' and @qualifier='volume'])"/>
		    </xsl:if>
		    <xsl:if test="//dim:field[@element='bibliographicCitation' and @qualifier='firstpage']">
			    <xsl:value-of select="concat(', p. ', //dim:field[@element='bibliographicCitation' and @qualifier='firstpage'])"/>
			    <xsl:if test="//dim:field[@element='bibliographicCitation' and @qualifier='lastpage']">
				    <xsl:value-of select="concat('-', //dim:field[@element='bibliographicCitation' and @qualifier='lastpage'])"/>
			    </xsl:if>
                    </xsl:if>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-toc">
        <xsl:if test="dim:field[@element='description' and @qualifier='tableofcontents' and descendant::text()]">
            <div class="simple-item-view-toc">
                <span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-toc</i18n:text>: </span>
                <xsl:choose>
                    <xsl:when test="contains(dim:field[@element='description' and @qualifier='tableofcontents'], ';')">
                        <ul>
                            <xsl:call-template name="split-list">
                                <xsl:with-param name="list">
                                    <xsl:value-of select="dim:field[@element='description' and @qualifier='tableofcontents']"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </ul>
                    </xsl:when>
                    <xsl:otherwise>
                        <span>
                            <xsl:copy-of select="dim:field[@element='description' and @qualifier='tableofcontents']"/>
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </xsl:if>
    </xsl:template>


    <xsl:template name="itemSummaryView-DIM-publisher">
        <xsl:if test="dim:field[@element='publisher' and  descendant::text()]">
            <div class="simple-item-view-other">
                <span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-publisher</i18n:text>: </span>
                <span>
                    <xsl:value-of select="dim:field[@element='publisher' and not(@qualifier)]"/>
                    <xsl:if test="//dim:field[@element='publisher'][@qualifier='place']">
                        <xsl:text>: </xsl:text><xsl:value-of select="//dim:field[@element='publisher'][@qualifier='place']"/>
                    </xsl:if>
                </span>
            </div>
        </xsl:if>
    </xsl:template>


    <xsl:template name="itemSummaryView-DIM-journalarticle">
        <xsl:if test="dim:field[@element='bibliographicCitation' and @qualifier='journal']">
		<div class="simple-item-view-other">
		<i18n:text><xsl:value-of select="//dim:field[@element='type']" /></i18n:text>
                        <xsl:for-each select="//dim:field[@element='language' and @qualifier='iso'] ">
                           <xsl:if test=". != 'other'">
                                <xsl:text> </xsl:text><i18n:text><xsl:value-of select="." /></i18n:text>
                                <xsl:if test="(position() != last())">
                                        <xsl:text>,</xsl:text>
                                </xsl:if>
                           </xsl:if>
                        </xsl:for-each>
		</div>
                <div class="simple-item-view-other">
                <span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-first-published</i18n:text>: </span>
                <span>
			<xsl:value-of select="dim:field[@element='bibliographicCitation' and @qualifier='journal']"/>
		    <xsl:value-of select="concat(' (', //dim:field[@element='date' and @qualifier='issued'],') ')"/>
                    <xsl:if test="//dim:field[@element='bibliographicCitation'][@qualifier='volume']">
                        <xsl:value-of select="//dim:field[@element='bibliographicCitation'][@qualifier='volume']"/>
		    </xsl:if>
		    <xsl:if test="//dim:field[@element='bibliographicCitation'][@qualifier='issue']">
                        <xsl:text>, </xsl:text><xsl:value-of select="//dim:field[@element='bibliographicCitation'][@qualifier='issue']"/>
		    </xsl:if>
		    <xsl:if test="//dim:field[@element='bibliographicCitation'][@qualifier='firstpage']">
			    <xsl:value-of select="concat(', p. ', //dim:field[@element='bibliographicCitation'][@qualifier='firstpage'])"/>
			    <xsl:if test="//dim:field[@element='bibliographicCitation'][@qualifier='lastpage']">
				    <xsl:value-of select="concat('-', //dim:field[@element='bibliographicCitation'][@qualifier='lastpage'])"/>
		            </xsl:if>
		    </xsl:if>
                </span>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-extent">
        <xsl:if test="dim:field[@qualifier='extent' and descendant::text()]">
            <div class="simple-item-view-other">
                <span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-extent</i18n:text>: </span>
                <span>
                    <xsl:value-of select="dim:field[@qualifier='extent']"/>
                </span>

            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-language">
     <xsl:if test="dim:field[@qualifier='language' and @qualifier='iso']">
        <div class="simple-item-view-other">
            <span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-language</i18n:text>: </span>
            <span>
                <xsl:for-each select="dim:field[@qualifier='iso']">
                    <i18n:text><xsl:value-of select="."/></i18n:text>
                    <xsl:if test="position() != last()"><xsl:text>, </xsl:text></xsl:if>
                </xsl:for-each>
            </span>
       </div>
    </xsl:if>
    </xsl:template>


    <xsl:template name="itemSummaryView-DIM-issn">
        <xsl:if test="dim:field[@qualifier='issn' and descendant::text()]">
            <div class="simple-item-view-other">
                <span class="bold"><i18n:text>ISSN</i18n:text>: </span>
                <span><xsl:value-of select="dim:field[@qualifier='issn']"/></span>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-isbn">
        <xsl:if test="(dim:field[@qualifier='isbn' or @qualifier='pISBN']) and descendant::text()">
            <div class="simple-item-view-other">
                <span class="bold">ISBN: </span>
                <span>
                    <xsl:value-of select="dim:field[@qualifier='isbn']"/>
                    <xsl:value-of select="dim:field[@qualifier='pISBN']"/>
                </span>
            </div>
        </xsl:if>
   </xsl:template>

    <xsl:template name="itemSummaryView-DIM-printedition">
        <xsl:for-each select="dim:field[@qualifier='relation' or @qualifier='print']">
	<div class="simple-item-view-other">
		<a>
		    <xsl:attribute name="href">
			    <xsl:value-of select="."/>
		    </xsl:attribute>
		    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-print-edition</i18n:text>
                </a>
            </div>
        </xsl:for-each>
   </xsl:template>

    <xsl:template name="itemSummaryView-DIM-doi">
        <xsl:for-each select="dim:field[@qualifier='identifier' or @qualifier='doi']">
		<div class="simple-item-view-other">
		<span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-doi</i18n:text>: </span>
                <a>
                    <xsl:attribute name="href">
                            <xsl:value-of select="."/>
		    </xsl:attribute>
		    <xsl:value-of select="."/>
                </a>
            </div>
        </xsl:for-each>
   </xsl:template>


    <xsl:template name="itemSummaryView-DIM-notes">
        <xsl:if test="dim:field[@qualifier='notes' and @qualifier != 'intern' and descendant::text()]">
            <div class="simple-item-view-other">


                <span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-notes</i18n:text>: </span>
                <span>
                    <xsl:for-each select="dim:field[@qualifier='notes' and @qualifier != 'intern']">
                        <xsl:value-of select="."/>
                    </xsl:for-each>
                </span>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-URI">
        <xsl:if test="dim:field[@element='identifier' and @qualifier='uri' and descendant::text()]">
            <div class="simple-item-view-bookmark">


                <span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-uri</i18n:text>: </span>
                <span>
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="dim:field[@element='identifier' and @qualifier='uri']"/>
                        </xsl:attribute>
                        <xsl:value-of select="dim:field[@element='identifier' and @qualifier='uri']"/>
                    </a>
                </span>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-date">
	    <xsl:if test="dim:field[@element='date' and @qualifier='issued'] and not(//dim:field[@element='bibliographicCitation' and @qualifier='journal'])">
                <div class="simple-item-view-other">
			<i18n:text><xsl:value-of select="//dim:field[@element='type']" /></i18n:text>
			<xsl:for-each select="//dim:field[@element='language' and @qualifier='iso'] ">
			   <xsl:if test=". != 'other'">
				<xsl:text> </xsl:text><i18n:text><xsl:value-of select="." /></i18n:text>
				<xsl:if test="(position() != last())">
					<xsl:text>,</xsl:text>
				</xsl:if>
			   </xsl:if>
			</xsl:for-each>
                </div>
                <div class="simple-item-view-other">
                    <span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-date</i18n:text>: </span>
                    <xsl:value-of select="dim:field[@element='date' and @qualifier='issued' and descendant::text()]"/>
                </div>
            </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-show-full">
        <div class="simple-item-view-show-full item-page-field-wrapper table">
		<!--<h5>
                <i18n:text>xmlui.mirage2.itemSummaryView.MetaData</i18n:text>
	    </h5> -->
            <a>
                <xsl:attribute name="href"><xsl:value-of select="$ds_item_view_toggle_url"/></xsl:attribute>
		<i18n:text>xmlui.ArtifactBrowser.ItemViewer.show_full</i18n:text> 
            </a>
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-collections">
        <xsl:if test="$document//dri:referenceSet[@id='aspect.artifactbrowser.ItemViewer.referenceSet.collection-viewer']">
            <div class="simple-item-view-collections item-page-field-wrapper table">
                <h5>
                    <i18n:text>xmlui.mirage2.itemSummaryView.Collections</i18n:text>
                </h5>
                <xsl:apply-templates select="$document//dri:referenceSet[@id='aspect.artifactbrowser.ItemViewer.referenceSet.collection-viewer']/dri:reference"/>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-file-section">
        <xsl:choose>
            <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">
                <div class="item-page-field-wrapper table word-break">
			<!-- <h5>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
		    </h5> -->
			<br />
                    <xsl:variable name="label-1">
                        <xsl:choose>
                            <xsl:when test="confman:getProperty('mirage2.item-view.bitstream.href.label.1')">
                                <xsl:value-of select="confman:getProperty('mirage2.item-view.bitstream.href.label.1')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>label</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>

                    <xsl:variable name="label-2">
                        <xsl:choose>
                            <xsl:when test="confman:getProperty('mirage2.item-view.bitstream.href.label.2')">
                                <xsl:value-of select="confman:getProperty('mirage2.item-view.bitstream.href.label.2')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>title</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>

                    <xsl:for-each select="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">
                        <xsl:call-template name="itemSummaryView-DIM-file-section-entry">
                            <xsl:with-param name="href" select="mets:FLocat[@LOCTYPE='URL']/@xlink:href" />
                            <xsl:with-param name="mimetype" select="@MIMETYPE" />
                            <xsl:with-param name="label-1" select="$label-1" />
                            <xsl:with-param name="label-2" select="$label-2" />
                            <xsl:with-param name="title" select="mets:FLocat[@LOCTYPE='URL']/@xlink:title" />
                            <xsl:with-param name="label" select="mets:FLocat[@LOCTYPE='URL']/@xlink:label" />
                            <xsl:with-param name="size" select="@SIZE" />
                        </xsl:call-template>
                    </xsl:for-each>
                </div>

            </xsl:when>
            <!-- Special case for handling ORE resource maps stored as DSpace bitstreams -->
            <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='ORE']">
                <xsl:apply-templates select="//mets:fileSec/mets:fileGrp[@USE='ORE']" mode="itemSummaryView-DIM" />
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-file-section-entry">
        <xsl:param name="href" />
        <xsl:param name="mimetype" />
        <xsl:param name="label-1" />
        <xsl:param name="label-2" />
        <xsl:param name="title" />
        <xsl:param name="label" />
        <xsl:param name="size" />
        <div>
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="$href"/>
                </xsl:attribute>
                <xsl:call-template name="getFileIcon">
                    <xsl:with-param name="mimetype">
                        <xsl:value-of select="substring-before($mimetype,'/')"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="substring-after($mimetype,'/')"/>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:choose>
                    <xsl:when test="contains($label-1, 'label') and string-length($label)!=0">
                        <xsl:value-of select="$label"/>
                    </xsl:when>
                    <xsl:when test="contains($label-1, 'title') and string-length($title)!=0">
                        <xsl:value-of select="$title"/>
                    </xsl:when>
                    <xsl:when test="contains($label-2, 'label') and string-length($label)!=0">
                        <xsl:value-of select="$label"/>
                    </xsl:when>
                    <xsl:when test="contains($label-2, 'title') and string-length($title)!=0">
                        <xsl:value-of select="$title"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="getFileTypeDesc">
                            <xsl:with-param name="mimetype">
                                <xsl:value-of select="substring-before($mimetype,'/')"/>
                                <xsl:text>/</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="contains($mimetype,';')">
                                        <xsl:value-of select="substring-before(substring-after($mimetype,'/'),';')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="substring-after($mimetype,'/')"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text> (</xsl:text>
                <xsl:choose>
                    <xsl:when test="$size &lt; 1024">
                        <xsl:value-of select="$size"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-bytes</i18n:text>
                    </xsl:when>
                    <xsl:when test="$size &lt; 1024 * 1024">
                        <xsl:value-of select="substring(string($size div 1024),1,5)"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-kilobytes</i18n:text>
                    </xsl:when>
                    <xsl:when test="$size &lt; 1024 * 1024 * 1024">
                        <xsl:value-of select="substring(string($size div (1024 * 1024)),1,5)"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-megabytes</i18n:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring(string($size div (1024 * 1024 * 1024)),1,5)"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-gigabytes</i18n:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>)</xsl:text>
            </a>
        </div>
    </xsl:template>

    <xsl:template match="dim:dim" mode="itemDetailView-DIM">
        <xsl:call-template name="itemSummaryView-DIM-title"/>
        <div class="ds-table-responsive">
            <table class="ds-includeSet-table detailtable table table-striped table-hover">
                <xsl:apply-templates mode="itemDetailView-DIM"/>
            </table>
        </div>

        <span class="Z3988">
            <xsl:attribute name="title">
                <xsl:call-template name="renderCOinS"/>
            </xsl:attribute>
            &#xFEFF; <!-- non-breaking space to force separating the end tag -->
        </span>
        <xsl:copy-of select="$SFXLink" />
    </xsl:template>

    <xsl:template match="dim:field" mode="itemDetailView-DIM">
        <tr>
            <xsl:attribute name="class">
                <xsl:text>ds-table-row </xsl:text>
                <xsl:if test="(position() div 2 mod 2 = 0)">even </xsl:if>
                <xsl:if test="(position() div 2 mod 2 = 1)">odd </xsl:if>
            </xsl:attribute>
            <td class="label-cell">
                <xsl:value-of select="./@mdschema"/>
                <xsl:text>.</xsl:text>
                <xsl:value-of select="./@element"/>
                <xsl:if test="./@qualifier">
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="./@qualifier"/>
                </xsl:if>
            </td>
            <td class="word-break">
                <xsl:copy-of select="./node()"/>
            </td>
            <td><xsl:value-of select="./@language"/></td>
        </tr>
    </xsl:template>

    <!-- don't render the item-view-toggle automatically in the summary view, only when it gets called -->
    <xsl:template match="dri:p[contains(@rend , 'item-view-toggle') and
        (preceding-sibling::dri:referenceSet[@type = 'summaryView'] or following-sibling::dri:referenceSet[@type = 'summaryView'])]">
    </xsl:template>

    <!-- don't render the head on the item view page -->
    <xsl:template match="dri:div[@n='item-view']/dri:head" priority="5">
    </xsl:template>

    <xsl:template match="mets:fileGrp[@USE='CONTENT']">
        <xsl:param name="context"/>
        <xsl:param name="primaryBitstream" select="-1"/>
        <xsl:choose>
            <!-- If one exists and it's of text/html MIME type, only display the primary bitstream -->
            <xsl:when test="mets:file[@ID=$primaryBitstream]/@MIMETYPE='text/html'">
                <xsl:apply-templates select="mets:file[@ID=$primaryBitstream]">
                    <xsl:with-param name="context" select="$context"/>
                </xsl:apply-templates>
            </xsl:when>
            <!-- Otherwise, iterate over and display all of them -->
            <xsl:otherwise>
                <xsl:apply-templates select="mets:file">
                    <!--Do not sort any more bitstream order can be changed-->
                    <xsl:with-param name="context" select="$context"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="mets:fileGrp[@USE='LICENSE']">
        <xsl:param name="context"/>
        <xsl:param name="primaryBitstream" select="-1"/>
        <xsl:apply-templates select="mets:file">
            <xsl:with-param name="context" select="$context"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="mets:file">
        <xsl:param name="context" select="."/>
        <div class="file-wrapper row">
            <div class="col-xs-6 col-sm-3">
                <div class="thumbnail">
                    <a class="image-link">
                        <xsl:attribute name="href">
                            <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                        mets:file[@GROUPID=current()/@GROUPID]">
                                <img class="img-thumbnail" alt="Thumbnail">
                                    <xsl:attribute name="src">
                                        <xsl:value-of select="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                                    mets:file[@GROUPID=current()/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                                    </xsl:attribute>
                                </img>
                            </xsl:when>
                            <xsl:otherwise>
                                <img class="img-thumbnail" alt="Thumbnail">
                                    <xsl:attribute name="data-src">
                                        <xsl:text>holder.js/100%x</xsl:text>
                                        <xsl:value-of select="$thumbnail.maxheight"/>
                                        <xsl:text>/text:No Thumbnail</xsl:text>
                                    </xsl:attribute>
                                </img>
                            </xsl:otherwise>
                        </xsl:choose>
                    </a>
                </div>
            </div>

            <div class="col-xs-6 col-sm-7">
                <dl class="file-metadata dl-horizontal">
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-name</i18n:text>
                        <xsl:text>: </xsl:text>
                    </dt>
                    <dd class="word-break">
                        <xsl:attribute name="title">
                            <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:title"/>
                        </xsl:attribute>
                        <xsl:value-of select="util:shortenString(mets:FLocat[@LOCTYPE='URL']/@xlink:title, 30, 5)"/>
                    </dd>
                    <!-- File size always comes in bytes and thus needs conversion -->
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-size</i18n:text>
                        <xsl:text>: </xsl:text>
                    </dt>
                    <dd class="word-break">
                        <xsl:choose>
                            <xsl:when test="@SIZE &lt; 1024">
                                <xsl:value-of select="@SIZE"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-bytes</i18n:text>
                            </xsl:when>
                            <xsl:when test="@SIZE &lt; 1024 * 1024">
                                <xsl:value-of select="substring(string(@SIZE div 1024),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-kilobytes</i18n:text>
                            </xsl:when>
                            <xsl:when test="@SIZE &lt; 1024 * 1024 * 1024">
                                <xsl:value-of select="substring(string(@SIZE div (1024 * 1024)),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-megabytes</i18n:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="substring(string(@SIZE div (1024 * 1024 * 1024)),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-gigabytes</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </dd>
                    <!-- Lookup File Type description in local messages.xml based on MIME Type.
             In the original DSpace, this would get resolved to an application via
             the Bitstream Registry, but we are constrained by the capabilities of METS
             and can't really pass that info through. -->
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-format</i18n:text>
                        <xsl:text>: </xsl:text>
                    </dt>
                    <dd class="word-break">
                        <xsl:call-template name="getFileTypeDesc">
                            <xsl:with-param name="mimetype">
                                <xsl:value-of select="substring-before(@MIMETYPE,'/')"/>
                                <xsl:text>/</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="contains(@MIMETYPE,';')">
                                        <xsl:value-of select="substring-before(substring-after(@MIMETYPE,'/'),';')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="substring-after(@MIMETYPE,'/')"/>
                                    </xsl:otherwise>
                                </xsl:choose>

                            </xsl:with-param>
                        </xsl:call-template>
                    </dd>
                    <!-- Display the contents of 'Description' only if bitstream contains a description -->
                    <xsl:if test="mets:FLocat[@LOCTYPE='URL']/@xlink:label != ''">
                        <dt>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-description</i18n:text>
                            <xsl:text>: </xsl:text>
                        </dt>
                        <dd class="word-break">
                            <xsl:attribute name="title">
                                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:label"/>
                            </xsl:attribute>
                            <xsl:value-of select="util:shortenString(mets:FLocat[@LOCTYPE='URL']/@xlink:label, 30, 5)"/>
                        </dd>
                    </xsl:if>
                </dl>
            </div>

            <div class="file-link col-xs-6 col-xs-offset-6 col-sm-2 col-sm-offset-0">
                <xsl:choose>
                    <xsl:when test="@ADMID">
                        <xsl:call-template name="display-rights"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="view-open"/>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </div>

    </xsl:template>

    <xsl:template name="view-open">
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
            </xsl:attribute>
            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
        </a>
    </xsl:template>

    <xsl:template name="display-rights">
        <xsl:variable name="file_id" select="jstring:replaceAll(jstring:replaceAll(string(@ADMID), '_METSRIGHTS', ''), 'rightsMD_', '')"/>
        <xsl:variable name="rights_declaration" select="../../../mets:amdSec/mets:rightsMD[@ID = concat('rightsMD_', $file_id, '_METSRIGHTS')]/mets:mdWrap/mets:xmlData/rights:RightsDeclarationMD"/>
        <xsl:variable name="rights_context" select="$rights_declaration/rights:Context"/>
        <xsl:variable name="users">
            <xsl:for-each select="$rights_declaration/*">
                <xsl:value-of select="rights:UserName"/>
                <xsl:choose>
                    <xsl:when test="rights:UserName/@USERTYPE = 'GROUP'">
                        <xsl:text> (group)</xsl:text>
                    </xsl:when>
                    <xsl:when test="rights:UserName/@USERTYPE = 'INDIVIDUAL'">
                        <xsl:text> (individual)</xsl:text>
                    </xsl:when>
                </xsl:choose>
                <xsl:if test="position() != last()">, </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="not ($rights_context/@CONTEXTCLASS = 'GENERAL PUBLIC') and ($rights_context/rights:Permissions/@DISPLAY = 'true')">
                <a href="{mets:FLocat[@LOCTYPE='URL']/@xlink:href}">
                    <img width="64" height="64" src="{concat($theme-path,'/images/Crystal_Clear_action_lock3_64px.png')}" title="Read access available for {$users}"/>
                    <!-- icon source: http://commons.wikimedia.org/wiki/File:Crystal_Clear_action_lock3.png -->
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="view-open"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="getFileIcon">
	    <xsl:param name="mimetype"/>
	    <xsl:if test="contains(mets:FLocat[@LOCTYPE='URL']/@xlink:href,'isAllowed=n')">
		<i>
		    <xsl:attribute name="class">
	                <xsl:text>glyphicon glyphicon-lock</xsl:text>
                    </xsl:attribute>
        	</i>
		<xsl:text> </xsl:text>
	    </xsl:if>
    </xsl:template>

    <!-- Generate the license information from the file section -->
    <xsl:template match="mets:fileGrp[@USE='CC-LICENSE']" mode="simple">
        <li><a href="{mets:file/mets:FLocat[@xlink:title='license_text']/@xlink:href}"><i18n:text>xmlui.dri2xhtml.structural.link_cc</i18n:text></a></li>
    </xsl:template>

    <!-- Generate the license information from the file section -->
    <xsl:template match="mets:fileGrp[@USE='LICENSE']" mode="simple">
        <li><a href="{mets:file/mets:FLocat[@xlink:title='license.txt']/@xlink:href}"><i18n:text>xmlui.dri2xhtml.structural.link_original_license</i18n:text></a></li>
    </xsl:template>

    <!--
    File Type Mapping template

    This maps format MIME Types to human friendly File Type descriptions.
    Essentially, it looks for a corresponding 'key' in your messages.xml of this
    format: xmlui.dri2xhtml.mimetype.{MIME Type}

    (e.g.) <message key="xmlui.dri2xhtml.mimetype.application/pdf">PDF</message>

    If a key is found, the translated value is displayed as the File Type (e.g. PDF)
    If a key is NOT found, the MIME Type is displayed by default (e.g. application/pdf)
    -->
    <xsl:template name="getFileTypeDesc">
        <xsl:param name="mimetype"/>

        <!--Build full key name for MIME type (format: xmlui.dri2xhtml.mimetype.{MIME type})-->
        <xsl:variable name="mimetype-key">xmlui.dri2xhtml.mimetype.<xsl:value-of select='$mimetype'/></xsl:variable>

        <!--Lookup the MIME Type's key in messages.xml language file.  If not found, just display MIME Type-->
        <i18n:text i18n:key="{$mimetype-key}"><xsl:value-of select="$mimetype"/></i18n:text>
    </xsl:template>


    <xsl:template name="split-list">
        <xsl:param name="list"/>
        <xsl:variable name="newlist" select="normalize-space($list)"/>
        <xsl:choose>
            <xsl:when test="contains($newlist, ';')">
                <xsl:variable name="first" select="substring-before($newlist, ';')"/>
                <xsl:variable name="remaining" select="substring-after($newlist, ';')"/>
                <li>
                    <xsl:value-of select="$first"/>
                </li>
                <xsl:call-template name="split-list">
                    <xsl:with-param name="list" select="$remaining"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <li>
                    <xsl:value-of select="$newlist"/>
                </li>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="split-content">
        <xsl:param name="list"/>
        <xsl:variable name="newlist" select="normalize-space($list)"/>
        <xsl:variable name="first" select="substring-before($newlist, ';')"/>
        <xsl:variable name="remaining" select="substring-after($newlist, ';')"/>

        <xsl:value-of select="$first"/><br />

        <xsl:choose>
            <xsl:when test="contains($remaining, ';')">
                <xsl:call-template name="split-content">
                    <xsl:with-param name="list" select="$remaining"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>

                <xsl:value-of select="$remaining"/>

            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="parts">
        <xsl:if test="//dim:field[@element='relation' and @qualifier='haspart']">
            <div class="parts">
                <span class="bold"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-haspart</i18n:text>: </span>
                <span>
                    <ul>
                        <xsl:for-each select="//dim:field[@element='relation' and @qualifier='haspart']">
                            <xsl:choose>
                                <xsl:when test="starts-with(., 'http')">
                                    <xsl:variable name="handle"><xsl:value-of select="substring-after(., 'hdl.handle.net')"/></xsl:variable>
                                    <xsl:variable name="metsfile"><xsl:value-of select="concat('cocoon://metadata/handle',$handle, '/mets.xml')"/></xsl:variable>
                                    <li>
                                        <a>
                                            <xsl:attribute name="href"><xsl:value-of select="."/></xsl:attribute>
                                            <xsl:value-of select="document($metsfile)//dim:field[@element='title']"/>
                                        </a>
                                    </li>
                                </xsl:when>
                                <xsl:otherwise>

                                    <xsl:value-of select="./node()"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </ul>
                </span>
            </div>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
