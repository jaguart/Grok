<map version="freeplane 1.9.13">
<!--To view this file, download free mind mapping software Freeplane from https://www.freeplane.org -->
<node TEXT="Grok::Graph" FOLDED="false" ID="ID_696401721" CREATED="1610381621824" MODIFIED="1672889820122" STYLE="oval">
<font SIZE="18"/>
<hook NAME="MapStyle">
    <properties edgeColorConfiguration="#808080ff,#ff0000ff,#0000ffff,#00ff00ff,#ff00ffff,#00ffffff,#7c0000ff,#00007cff,#007c00ff,#7c007cff,#007c7cff,#7c7c00ff" fit_to_viewport="false" associatedTemplateLocation="template:/standard-1.6.mm"/>

<map_styles>
<stylenode LOCALIZED_TEXT="styles.root_node" STYLE="oval" UNIFORM_SHAPE="true" VGAP_QUANTITY="24 pt">
<font SIZE="24"/>
<stylenode LOCALIZED_TEXT="styles.predefined" POSITION="right" STYLE="bubble">
<stylenode LOCALIZED_TEXT="default" ID="ID_271890427" ICON_SIZE="12 pt" COLOR="#000000" STYLE="fork">
<arrowlink SHAPE="CUBIC_CURVE" COLOR="#000000" WIDTH="2" TRANSPARENCY="200" DASH="" FONT_SIZE="9" FONT_FAMILY="SansSerif" DESTINATION="ID_271890427" STARTARROW="NONE" ENDARROW="DEFAULT"/>
<font NAME="SansSerif" SIZE="10" BOLD="false" ITALIC="false"/>
<richcontent CONTENT-TYPE="plain/auto" TYPE="DETAILS"/>
<richcontent TYPE="NOTE" CONTENT-TYPE="plain/auto"/>
</stylenode>
<stylenode LOCALIZED_TEXT="defaultstyle.details"/>
<stylenode LOCALIZED_TEXT="defaultstyle.attributes">
<font SIZE="9"/>
</stylenode>
<stylenode LOCALIZED_TEXT="defaultstyle.note" COLOR="#000000" BACKGROUND_COLOR="#ffffff" TEXT_ALIGN="LEFT"/>
<stylenode LOCALIZED_TEXT="defaultstyle.floating">
<edge STYLE="hide_edge"/>
<cloud COLOR="#f0f0f0" SHAPE="ROUND_RECT"/>
</stylenode>
<stylenode LOCALIZED_TEXT="defaultstyle.selection" BACKGROUND_COLOR="#afd3f7" BORDER_COLOR_LIKE_EDGE="false" BORDER_COLOR="#afd3f7"/>
</stylenode>
<stylenode LOCALIZED_TEXT="styles.user-defined" POSITION="right" STYLE="bubble">
<stylenode LOCALIZED_TEXT="styles.topic" COLOR="#18898b" STYLE="fork">
<font NAME="Liberation Sans" SIZE="10" BOLD="true"/>
</stylenode>
<stylenode LOCALIZED_TEXT="styles.subtopic" COLOR="#cc3300" STYLE="fork">
<font NAME="Liberation Sans" SIZE="10" BOLD="true"/>
</stylenode>
<stylenode LOCALIZED_TEXT="styles.subsubtopic" COLOR="#669900">
<font NAME="Liberation Sans" SIZE="10" BOLD="true"/>
</stylenode>
<stylenode LOCALIZED_TEXT="styles.important" ID="ID_67550811">
<icon BUILTIN="yes"/>
<arrowlink COLOR="#003399" TRANSPARENCY="255" DESTINATION="ID_67550811"/>
</stylenode>
</stylenode>
<stylenode LOCALIZED_TEXT="styles.AutomaticLayout" POSITION="right" STYLE="bubble">
<stylenode LOCALIZED_TEXT="AutomaticLayout.level.root" COLOR="#000000" STYLE="oval" SHAPE_HORIZONTAL_MARGIN="10 pt" SHAPE_VERTICAL_MARGIN="10 pt">
<font SIZE="18"/>
</stylenode>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,1" COLOR="#0033ff">
<font SIZE="16"/>
</stylenode>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,2" COLOR="#00b439">
<font SIZE="14"/>
</stylenode>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,3" COLOR="#990000">
<font SIZE="12"/>
</stylenode>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,4" COLOR="#111111">
<font SIZE="10"/>
</stylenode>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,5"/>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,6"/>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,7"/>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,8"/>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,9"/>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,10"/>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,11"/>
</stylenode>
</stylenode>
</map_styles>
</hook>
<hook NAME="AutomaticEdgeColor" COUNTER="3" RULE="ON_BRANCH_CREATION"/>
<node TEXT="purpose" POSITION="right" ID="ID_516625221" CREATED="1672872356462" MODIFIED="1672872364796">
<edge COLOR="#ff0000"/>
<node TEXT="traverse a collection of nodes" ID="ID_77760732" CREATED="1672872365158" MODIFIED="1672872372160"/>
<node TEXT="walk a tree" ID="ID_1327419364" CREATED="1672872372447" MODIFIED="1672872375444"/>
<node TEXT="Iterator" ID="ID_1240600502" CREATED="1672872375883" MODIFIED="1672872831225">
<node TEXT="pull-one" ID="ID_1189507254" CREATED="1672872455357" MODIFIED="1672872840461">
<node TEXT="return next one or sentinel value IterationEnd" ID="ID_1656824513" CREATED="1672872504681" MODIFIED="1672872880024"/>
</node>
<node TEXT="is-lazy" ID="ID_1892735936" CREATED="1672873131036" MODIFIED="1672873136093">
<node TEXT="True or False" ID="ID_1089239405" CREATED="1672873136525" MODIFIED="1672873144717"/>
</node>
<node TEXT="sink-all" ID="ID_937467779" CREATED="1672873182555" MODIFIED="1672873187909">
<node TEXT="exhaust the iterator - make it a virtual no-op if there are no side effects" ID="ID_281426822" CREATED="1672873188491" MODIFIED="1672873213260"/>
</node>
<node TEXT="note" ID="ID_179787166" CREATED="1672872477615" MODIFIED="1672872927033">
<node TEXT="There are also optional Iterator API methods that will only be called if they are implemented by the consuming class: these are not implemented by the Iterator role." ID="ID_907072921" CREATED="1672872929042" MODIFIED="1672872930441"/>
<node TEXT="Only one iteration over the entire sequence" ID="ID_1294778617" CREATED="1672872945523" MODIFIED="1672872949680"/>
</node>
</node>
</node>
<node TEXT="raku" POSITION="left" ID="ID_867527402" CREATED="1672872460469" MODIFIED="1672877180841">
<edge COLOR="#0000ff"/>
<node TEXT="does Iterable → I can return an Iterator&#xa;  does Iterator → I can pull-one off creator" ID="ID_1770614189" CREATED="1672872460741" MODIFIED="1672877500077"/>
</node>
<node TEXT="traversal" POSITION="left" ID="ID_238211452" CREATED="1672877612506" MODIFIED="1672877615397">
<edge COLOR="#00ff00"/>
<node TEXT="terms" ID="ID_109497296" CREATED="1672877676104" MODIFIED="1672877678685">
<node ID="ID_1189626545" CREATED="1672877619195" MODIFIED="1672890172452"><richcontent TYPE="NODE">

<html>
  <head>
    
  </head>
  <body>
    <p>
      <b>node</b>, root, child, parent, edge
    </p>
  </body>
</html>

</richcontent>
</node>
<node TEXT="node aka: vertex, pl. verticies" ID="ID_149831251" CREATED="1672878003103" MODIFIED="1672887099229"/>
<node TEXT="leaf - node with no children" ID="ID_113818537" CREATED="1672877880080" MODIFIED="1672877890949"/>
<node TEXT="graph: network of verticies and edges" ID="ID_1788938773" CREATED="1672887168852" MODIFIED="1672887178725"/>
<node TEXT="internal - at least 1 child" ID="ID_1338348206" CREATED="1672877681454" MODIFIED="1672877687049"/>
<node TEXT="depth - distance from root" ID="ID_27943710" CREATED="1672877687856" MODIFIED="1672877696676"/>
<node TEXT="level - number of edges to root + 1, aka depth + 1" ID="ID_1210765228" CREATED="1672877697572" MODIFIED="1672877753497"/>
<node TEXT="height - count of edges for longest path between node and descendant leaf" ID="ID_1227116843" CREATED="1672877767579" MODIFIED="1672890130909"/>
<node TEXT="breadth - number of leafs" ID="ID_644255420" CREATED="1672877798351" MODIFIED="1672877808373"/>
<node TEXT="sub-tree - a non-root node" ID="ID_1050240124" CREATED="1672877814692" MODIFIED="1672877849780"/>
<node TEXT="DAG - directed acyclic graph" ID="ID_477917072" CREATED="1672887354459" MODIFIED="1672887363157"/>
<node TEXT="Two vertices are adjacent when they are both incident to a common edge" ID="ID_989611119" CREATED="1672887206999" MODIFIED="1672887208442"/>
<node TEXT="topological sort - order verticies by directed edges so that  least-targeted come before most-targeted" ID="ID_1809435558" CREATED="1672887385744" MODIFIED="1672887556822"/>
<node ID="ID_1123450686" CREATED="1672887231823" MODIFIED="1672890158100"><richcontent TYPE="NODE">

<html>
  <head>
    
  </head>
  <body>
    <p>
      <b>path - </b>sequence of adjacent vertices
    </p>
  </body>
</html>

</richcontent>
</node>
<node TEXT="traversal, travel, search, walk" ID="ID_1979679544" CREATED="1672877933704" MODIFIED="1672887642465">
<node TEXT="dfs" ID="ID_239416357" CREATED="1672877957322" MODIFIED="1672877961814">
<node TEXT="depth first search" ID="ID_1096125310" CREATED="1672877962950" MODIFIED="1672877967345">
<node TEXT="in-order traversal" ID="ID_1238829781" CREATED="1672878077442" MODIFIED="1672878088645"/>
</node>
<node TEXT="all nodes of each branch as deeply as possible before backtrace" ID="ID_381145537" CREATED="1672877968119" MODIFIED="1672877993001"/>
<node TEXT="NLR - preorder - Node, Left, Right" ID="ID_1912532299" CREATED="1672887700783" MODIFIED="1672887791058"/>
<node TEXT="LRN - Postorder - Left, Right, Node" ID="ID_24357096" CREATED="1672887717884" MODIFIED="1672887812809"/>
<node TEXT="LNR - Inorder - Left Node Right" ID="ID_997460868" CREATED="1672887726397" MODIFIED="1672887833613"/>
<node TEXT="and reverses of above" ID="ID_1014143566" CREATED="1672887841508" MODIFIED="1672887846862"/>
</node>
<node TEXT="bfs" ID="ID_356034691" CREATED="1672878005802" MODIFIED="1672878009008">
<node TEXT="breadth first search" ID="ID_401203757" CREATED="1672878010844" MODIFIED="1672878018221"/>
<node TEXT="all nodes at current depth before moving to next depth" ID="ID_1547016794" CREATED="1672878026764" MODIFIED="1672878048829"/>
<node TEXT="also iterative deepening search" ID="ID_1226941452" CREATED="1672888338860" MODIFIED="1672888346330"/>
</node>
<node TEXT="terms" ID="ID_1108476028" CREATED="1672890047025" MODIFIED="1672890060620">
<node TEXT="traverse" ID="ID_1672916875" CREATED="1672890062066" MODIFIED="1672890065012"/>
<node TEXT="walk" ID="ID_1227542918" CREATED="1672890065866" MODIFIED="1672890067484"/>
<node TEXT="navigate" ID="ID_1840132782" CREATED="1672890068370" MODIFIED="1672890071391"/>
<node TEXT="search" ID="ID_1578682337" CREATED="1672890072266" MODIFIED="1672890077180"/>
<node TEXT="visit" ID="ID_1746036115" CREATED="1672890078118" MODIFIED="1672890080455"/>
<node TEXT="explore" ID="ID_1443012031" CREATED="1672890245710" MODIFIED="1672890248560"/>
<node TEXT="roam" ID="ID_1347014774" CREATED="1672890252598" MODIFIED="1672890255032"/>
</node>
</node>
</node>
</node>
</node>
</map>
