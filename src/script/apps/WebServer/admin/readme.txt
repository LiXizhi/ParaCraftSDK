---++ Readme for NPL admin site
Author: LiXizhi@yeah.net
Date: 2015.6.23
License: LGPL, free for any use. 

---++ Introduction
WebServer/admin is a NPL based web site framework. I have implemented it according to the famous WordPress.org blog site. The default theme template is based on "sensitive" which is a free theme of wordpress. "sensitive" theme has no dependency on media and can adjust display and layout according to screen width, which is suitable for showing on mobile phone device. 

---++ How to use
   * copy everything in this folder to your own web site root, say /www/MySite/
   * modify wp-content/database/*.xml for site description and menus. 
   * add your own web pages to wp-content/pages/, which are accessed by their filename in the url.
   * If you want more customization to the look, modify the wp-content/themes/sensitive or create your own theme folder. Remember to set your theme in wp-content/database/table_sitemeta.xml, which contains all options for the site. 

---++ Architecture
	The architecture is based on Wordpress.org (4.0.1). Although everything is rewritten in NPL, I have kept all functions, filters, and file names identical to wordpress. 
	See wp-includes/ for the framework source code.

Code locations:
	* framework loader is in wp-settings.page
	* site options: wp-content/database/table_sitemeta.xml: such as theme, default menu, etc.
	* menus: wp-content/database/table_nav_menu.xml

---++ Ajax framework
	Any request url begins with "ajax/xxx" use the wp-admin/admin-ajax.page. it will automatically load the page xxx.  and invoke do_action('wp_ajax_xxx'). 
	If the request url begins with "ajax/xxx?action=yyy", then page xxx is loaded, and do_action('wp_ajax_xxx') is invoked. 
	A page that handles ajax request needs to call add_action('wp_ajax_xxx'£¬ function_name) to register a handler for ajax actions. 
	see wp-content/pages/aboutus.page for an example. 
