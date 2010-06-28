/*
  Copyright (c) 1999 - 2010, Vodafone Group Services Ltd
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  * Neither the name of the Vodafone Group Services Ltd nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "LocalizationHandler.h"

static NSMutableDictionary *LOCALIZED_STRINGS;

@implementation LocalizationHandler

+ (void)initialize {
	// PLEASE DO NOT REMOVE THE FOLLOWING LINES, ALTHOUGH THEY ARE COMMENTED OUT
	// THEY ARE USED WHEN GENERATING NEW LANGUAGE CODE FILES FOR THE LOCALIZATION TOOL
	
	///////////////// LOCALIZATION TOOL BEGIN -> enable when updating list of supported iPhone languages /////////////////
	//[LocalizationHandler writeLanguageCodeFile];
	///////////////// LOCALIZATION TOOL END /////////////////
	
	NSLog(@"Initializing localized Strings...");
	LOCALIZED_STRINGS = [[NSMutableDictionary alloc] init];

	// internal strings
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"WF_TEXT", nil, [NSBundle mainBundle], @"5", @"TEXT language to use in Navigator app.") forKey:@"WF_TEXT"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"WF_VOICE", nil, [NSBundle mainBundle], @"5", @"VOICE language to use in Navigator app.") forKey:@"WF_VOICE"];
	
	// popup titles
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"[iPh_calc_route_txt]", nil, [NSBundle mainBundle], @"Calculating route...", @"to show while waiting for server to deliver route callback") forKey:@"[iPh_calc_route_txt]"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"[purchase_popup_title]", nil, [NSBundle mainBundle], @"TBD", @"dialog title when using in app purchases - NOTE: NOT USED!") forKey:@"[purchase_popup_title]"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"[iPh_waiting_for_gps_title]", nil, [NSBundle mainBundle], @"Waiting for GPS signal...", @"Message to be shown when waiting for GPS signal") forKey:@"[iPh_waiting_for_gps_title]"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"[no_favourites_title]", nil, [NSBundle mainBundle], @"No saved places", @"Title for dialog when user goes to 'My places' view and has no saved places") forKey:@"[no_favourites_title]"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"[iPh_routing_failed_tk]", nil, [NSBundle mainBundle], @"Routing failed", @"Alert view title") forKey:@"[iPh_routing_failed_tk]"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_error_txt", nil, [NSBundle mainBundle], @"Error", @"Title for dialog when an error has occured") forKey:@"iPh_error_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_no_results_txt", nil, [NSBundle mainBundle], @"No results", @"Title for dialog when no search results was found") forKey:@"iPh_no_results_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_resume_txt", nil, [NSBundle mainBundle], @"Resume", @"Resume navigation dialog title") forKey:@"iPh_resume_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_safety_mess_title", nil, [NSBundle mainBundle], @"Safety warning", @"Title for safety warning dialog") forKey:@"iPh_safety_mess_title"];
	// ok, this is not a regular popup, but close enough
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_my_position_txt", nil, [NSBundle mainBundle], @"My position", @"Headline in pop-up dialog displaying address of current position") forKey:@"iPh_my_position_txt"];
	
	// popup messages
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"[no-country-selected]", nil, [NSBundle mainBundle], @"Please select a country before searching.", @"Content of error message displayed when 'Search' button is pressed (and 'Around me' mode is off), before a country has been chosen.") forKey:@"[no-country-selected]"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"[no-category-selected]", nil, [NSBundle mainBundle], @"Please select a category before searching.", @"Content of error message displayed when 'Search' button is pressed in 'Categories' view, before a category has been chosen.") forKey:@"[no-category-selected]"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"[no_favourites_message]", nil, [NSBundle mainBundle], @"You have not saved any places!", @"Message for dialog when user goes to 'My places' view and has no saved places") forKey:@"[no_favourites_message]"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"[disable_wifi_message]", nil, [NSBundle mainBundle], @"Please turn off Wi-Fi in order to use Navigation.", @"Startup warning message") forKey:@"[disable_wifi_message]"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_resume_navigation_txt", nil, [NSBundle mainBundle], @"Do you want to resume navigation?", @"Resume navigation dialog content") forKey:@"iPh_resume_navigation_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_safety_mess_txt", nil, [NSBundle mainBundle], @"Do not operate the application or phone while driving and remember that the road traffic regulations have priority over the navigation instructions.", @"Warning Message") forKey:@"iPh_safety_mess_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_unable_2_add_2_my_places_txt", nil, [NSBundle mainBundle], @"Unable to add this place to My Places. Please try again.", @"Body of the popup message, if adding a place to favourites fails") forKey:@"iPh_unable_2_add_2_my_places_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_unnable_2_connect_txt", nil, [NSBundle mainBundle], @"Unable to connect to the network. To use Vodafone navigation you need to turn off the Wi-fi connection and have a working Vodafone SIM card. You also need to check your connection settings.", @"When Iphone client starts, network can fail. This may be due to the following three reasons: You are not a Vodafone customer, you are using Wi-Fi or there is another/real problem with the connection.")  forKey:@"iPh_unnable_2_connect_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"serv_iPh_buy_add_subscrq_txt", nil, [NSBundle mainBundle], @"Navigation to %s is not possible based on your current subscription. Do you want to buy an additional subscription? This subscription will be valid for the next 12 months.", @"Renewal required alert message") forKey:@"serv_iPh_buy_add_subscrq_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"serv_iPh_trial_expiredq_txt", nil, [NSBundle mainBundle], @"The trial period of Vodafone Navigation has expired. If you want to navigate to %s you will need to purchase a 12 months subscription that lets you navigate within %s. Do you want to purchase this subscription?",  @"Trial period expired alert message") forKey:@"serv_iPh_trial_expiredq_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"wid_no_result_found_txt", nil, [NSBundle mainBundle], @"The search returned no results. Please redefine your search.", @"Body of the popup message, if the user tries to make a search and no search results were found") forKey:@"wid_no_result_found_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_route_cant_b_calc_2_req_pos_txt", nil, [NSBundle mainBundle], @"Unable to calculate route to your destination. Choose a different destination. ", @"Error message when destination is not reachable (eg. in the middle of the ocean)") forKey:@"iPh_route_cant_b_calc_2_req_pos_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_route_cant_b_calc_from_ur_pos_txt", nil, [NSBundle mainBundle], @"Unable to calculate route from your current position.", @"Error message when origin is not reachable (eg. User is not on land - but maybe sailing in the ocean)") forKey:@"iPh_route_cant_b_calc_from_ur_pos_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_route_invalid_txt", nil, [NSBundle mainBundle], @"Route is invalid. Please try again.", @"Error message when route is invalid.") forKey:@"iPh_route_invalid_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"[no_gps_signal]", nil, [NSBundle mainBundle], @"GPS position not available. Please try again.", @"Error message when a GPS position can not be established as origin for a route.") forKey:@"[no_gps_signal]"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"[no_route_found]", nil, [NSBundle mainBundle], @"There is no way to get from the origin to the destination.", @"Error message when routing fails, because eg. origin and destination are on two different (non-attached) continents.") forKey:@"[no_route_found]"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"[route_unknown_fail]", nil, [NSBundle mainBundle], @"Routing failed for an unknown reason. Please try again.", @"Error message when routing fails, and we don't know why.") forKey:@"[route_unknown_fail]"];
	
	// checkbox label texts
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_dont_show_cb_txt", nil, [NSBundle mainBundle], @"Don't show this again", @"A check box, the user can either mark it or not, to not show the referred message again.") forKey:@"iPh_dont_show_cb_txt"];
	
	// touch key texts
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"[iPh_2D_perspective]", nil, [NSBundle mainBundle], @"2D", @"Touch key name (2D/3D perspective button)") forKey:@"[iPh_2D_perspective]"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"[iPh_3D_perspective]", nil, [NSBundle mainBundle], @"3D", @"Touch key name (2D/3D perspective button)") forKey:@"[iPh_3D_perspective]"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"[exit_button]", nil, [NSBundle mainBundle], @"Exit", @"Touch key name (Exit button in pop-up dialogue)") forKey:@"[exit_button]"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"[retry_button]", nil, [NSBundle mainBundle], @"Retry", @"Touch key name (Retry button in pop-up dialogue)") forKey:@"[retry_button]"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_accept_tk", nil, [NSBundle mainBundle], @"Accept", @"Touch key name") forKey:@"iPh_accept_tk"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_cancel_tk", nil, [NSBundle mainBundle], @"Cancel", @"Touch key name (Cancel current operation)") forKey:@"iPh_cancel_tk"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_day_tk", nil, [NSBundle mainBundle], @"Day", @"Touch key name (Change map view to Day mode)") forKey:@"iPh_day_tk"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_done_tk", nil, [NSBundle mainBundle], @"Done", @"Touch key name (Done with navigating - replaces cancel button when destination is reached)") forKey:@"iPh_done_tk"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_night_tk", nil, [NSBundle mainBundle], @"Night", @"Touch key name (Change map view to Night mode)") forKey:@"iPh_night_tk"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_no_tk", nil, [NSBundle mainBundle], @"No", @"Touch key name") forKey:@"iPh_no_tk"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_ok_tk", nil, [NSBundle mainBundle], @"OK", @"Touch key name (OK button in pop-up dialogue)") forKey:@"iPh_ok_tk"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_reject_tk", nil, [NSBundle mainBundle], @"Reject", @"Touch key name") forKey:@"iPh_reject_tk"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_search_tk", nil, [NSBundle mainBundle], @"Search", @"Touch key name (Select general search function)") forKey:@"iPh_search_tk"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_start_nav_tk", nil, [NSBundle mainBundle], @"Start navigation", @"Touch key name (Start navigation)") forKey:@"iPh_start_nav_tk"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_yes_tk", nil, [NSBundle mainBundle], @"Yes", @"Touch key name") forKey:@"iPh_yes_tk"];
	
	// navigation bar button texts
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"[done_nav_button]", nil, [NSBundle mainBundle], @"Done", @"Touch key name (Done with current task button in navigation bar)") forKey:@"[done_nav_button]"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_back_tk", nil, [NSBundle mainBundle], @"Back", @"Touch key name (to navigate back to previous view in navigation bar)") forKey:@"iPh_back_tk"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_edit_tk", nil, [NSBundle mainBundle], @"Edit", @"Touch key name (Edit button in navigation bar to edit the details of the selected place)") forKey:@"iPh_edit_tk"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_history_tk", nil, [NSBundle mainBundle], @"History", @"Touch key name (to show history page in navigation bar)") forKey:@"iPh_history_tk"];
	
	// tab bar button texts
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_add_to_tk", nil, [NSBundle mainBundle], @"Add to", @"Touch key name (Add the selected place to 'My places' list - tab bar button label)") forKey:@"iPh_add_to_tk"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_navigate_to_tk", nil, [NSBundle mainBundle], @"Navigate to", @"Touch key name (Navigate to the selected place - tab bar button label)") forKey:@"iPh_navigate_to_tk"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_remove_tk", nil, [NSBundle mainBundle], @"Remove", @"Touch key name (Remove the selected place from 'My places' list - tab bar button label)") forKey:@"iPh_remove_tk"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_show_on_map_tk", nil, [NSBundle mainBundle], @"Show on map", @"Touch key name (Show the selected place on the map - tab bar button label)") forKey:@"iPh_show_on_map_tk"];
	
	// segment control button texts
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_list_tk", nil, [NSBundle mainBundle], @"List", @"Touch key name (List view type selection in toolbar segment control) ") forKey:@"iPh_list_tk"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_map_tk", nil, [NSBundle mainBundle], @"Map", @"Touch key name (Map view type selection in toolbar segment control)") forKey:@"iPh_map_tk"];
	
	// placeholder texts for input fields
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"[select_category]", nil, [NSBundle mainBundle], @"Select category", @"Display in category field on search page, when no category has been selected!") forKey:@"[select_category]"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"[select_country]", nil, [NSBundle mainBundle], @"Select country", @"Display in country field on main page, when no country has been selected!") forKey:@"[select_country]"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"[street_name_and_number]", nil, [NSBundle mainBundle], @"Street name and house number", @"Placeholder text for street name field on main menu") forKey:@"[street_name_and_number]"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"[city_or_zip]", nil, [NSBundle mainBundle], @"City name or zipcode", @"Placeholder text for city/zip field on main menu") forKey:@"[city_or_zip]"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_all_categ_txt", nil, [NSBundle mainBundle], @"All Categories", @"Title for category 'All Categories'") forKey:@"iPh_all_categ_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_current_location_txt", nil, [NSBundle mainBundle], @"Determining current location...", @"Temporary text while waiting for reverse geocoding to display address in location field on search page (when 'Around me' is ON)") forKey:@"iPh_current_location_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_location_txt", nil, [NSBundle mainBundle], @"Location (eg. City)", @"Placeholder text for location on search page") forKey:@"iPh_location_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_street_ph_no_comp_txt", nil, [NSBundle mainBundle], @"Street, phone no., company", @"Placeholder text for search term on search page") forKey:@"iPh_street_ph_no_comp_txt"];

	// text labels for table cells
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"[enable_speed_zoom]", nil, [NSBundle mainBundle], @"Enable Speed Zoom", @"Text label for a table cell that goes to the account page") forKey:@"[enable_speed_zoom]"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"[account_table_cell_text]", nil, [NSBundle mainBundle], @"Account", @"Text label for a table cell that goes to the account page") forKey:@"[account_table_cell_text]"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"[settings_table_cell_text]", nil, [NSBundle mainBundle], @"Settings", @"Text label for a table cell that goes to the account page") forKey:@"[settings_table_cell_text]"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"[favourites_table_cell_text]", nil, [NSBundle mainBundle], @"My places", @"Text label for a table cell that goes to the favourites page") forKey:@"[favourites_table_cell_text]"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"[search_table_cell_text]", nil, [NSBundle mainBundle], @"Search", @"Text label for a table cell that goes to the search page") forKey:@"[search_table_cell_text]"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"[take_me_home_text]", nil, [NSBundle mainBundle], @"Take me home", @"Text label fot a table cell that goes to navigation to your 'home' - NOTE: NOT USED YET!") forKey:@"[take_me_home_text]"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_distance_units_sett_txt", nil, [NSBundle mainBundle], @"Distance units", @"Table cell label for Distance Units") forKey:@"iPh_distance_units_sett_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_show_categ_sett_txt", nil, [NSBundle mainBundle], @"Show categories", @"Show categories Label") forKey:@"iPh_show_categ_sett_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_traffic_updates_txt", nil, [NSBundle mainBundle], @"Traffic updates", @"Table cell label for traffic updates") forKey:@"iPh_traffic_updates_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_poi_downloads_txt", nil, [NSBundle mainBundle], @"POI Downloads", @"Table cell label for poi downloads") forKey:@"iPh_poi_downloads_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_client_type_sett_txt", nil, [NSBundle mainBundle], @"Client type", @"Table cell label for Client Types") forKey:@"iPh_client_type_sett_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_my_current_location_txt", nil, [NSBundle mainBundle], @"My current location:", @"My current position label") forKey:@"iPh_my_current_location_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_no_address_txt", nil, [NSBundle mainBundle], @"No address", @"Text used in the main menu, just under the title bar, where we usually display the user's current location or the text 'Determining current location...'. The 'No address' text will be displayed, if we can't get a 'real' location.") forKey:@"iPh_no_address_txt"];

	// settings table cell labels
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_gps_connection_txt", nil, [NSBundle mainBundle], @"GPS Connection", @"Label for GPS Connection") forKey:@"iPh_gps_connection_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_gprs_connection_txt", nil, [NSBundle mainBundle], @"GPRS Connection", @"Label for Keep GPRS Alive") forKey:@"iPh_gprs_connection_txt"];
//	[LOCALIZED_STRINGS setObject:NS LocalizedStringWithDefaultValue(@"iPh_distance_units_sett_txt", nil, [NSBundle mainBundle], @"Distance units", @"Label for Distance Units") forKey:@"iPh_distance_units_sett_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_route_optimisation_sett_txt", nil, [NSBundle mainBundle], @"Route optimisation", @"Label for Route Optimisation") forKey:@"iPh_route_optimisation_sett_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_voice_guidance_txt", nil, [NSBundle mainBundle], @"Voice guidance", @"Label for Voice guidance") forKey:@"iPh_voice_guidance_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_use_toll_roads_txt", nil, [NSBundle mainBundle], @"Use toll roads", @"Label for Use Toll Roads") forKey:@"iPh_use_toll_roads_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_use_motorways_txt", nil, [NSBundle mainBundle], @"Use motorways", @"Label for Use Motorways") forKey:@"iPh_use_motorways_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_traffic_updates_sett_txt", nil, [NSBundle mainBundle], @"Traffic updates", @"Label for traffic updates") forKey:@"iPh_traffic_updates_sett_txt"];
//	[LOCALIZED_STRINGS setObject:NSL ocalizedStringWithDefaultValue(@"iPh_poi_downloads_txt", nil, [NSBundle mainBundle], @"POI Downloads", @"Label for poi downloads") forKey:@"iPh_poi_downloads_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_logged_in_sett_txt", nil, [NSBundle mainBundle], @"Logged in", @"Label for account status") forKey:@"iPh_logged_in_sett_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_username_sett_txt", nil, [NSBundle mainBundle], @"Username", @"Label for username") forKey:@"iPh_username_sett_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_password_sett_txt", nil, [NSBundle mainBundle], @"Password", @"Label for password") forKey:@"iPh_password_sett_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_explicit_postion_txt", nil, [NSBundle mainBundle], @"Explicit postion", @"Label for Explicit postion") forKey:@"iPh_explicit_postion_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_latitude_sett_txt", nil, [NSBundle mainBundle], @"Latitude", @"Label for latitude") forKey:@"iPh_latitude_sett_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_longitude_sett_txt", nil, [NSBundle mainBundle], @"Longitude", @"Label for longitude") forKey:@"iPh_longitude_sett_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_clientserver_sett_txt", nil, [NSBundle mainBundle], @"Client type", @"Label for client server") forKey:@"iPh_clientserver_sett_txt"];
	// value table cell labels in settings
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_normal_sett_tk", nil, [NSBundle mainBundle], @"Normal", @"Normal value for backlight - table cell text") forKey:@"iPh_normal_sett_tk"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_before_turns_sett_tk", nil, [NSBundle mainBundle], @"Before turns", @"Before turns value for backlight - table cell text") forKey:@"iPh_before_turns_sett_tk"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_only_on_route_sett_tk", nil, [NSBundle mainBundle], @"Only on route", @"Only on route value for backlight - table cell text") forKey:@"iPh_only_on_route_sett_tk"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_always_on_tk", nil, [NSBundle mainBundle], @"Always on", @"always on value for backlight - table cell text") forKey:@"iPh_always_on_tk"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_metric_sett_tk", nil, [NSBundle mainBundle], @"Metric", @"Metric value for distance unit - table cell text") forKey:@"iPh_metric_sett_tk"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_miles_feet_sett_tk", nil, [NSBundle mainBundle], @"Miles, feet", @"Miles, feet value for distance unit - table cell text") forKey:@"iPh_miles_feet_sett_tk"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_miles_yards_sett_tk", nil, [NSBundle mainBundle], @"Miles, yards", @"Miles, yards value for distance unit - table cell text") forKey:@"iPh_miles_yards_sett_tk"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_fastest_route_sett_tk", nil, [NSBundle mainBundle], @"Fastest route", @"Fastest route value for route optimisation types - table cell text") forKey:@"iPh_fastest_route_sett_tk"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_shortest_route_sett_tk", nil, [NSBundle mainBundle], @"Shortest route", @"Shortest route value for route optimisation types - table cell text") forKey:@"iPh_shortest_route_sett_tk"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_limited_sett_tk", nil, [NSBundle mainBundle], @"Limited", @"Limited POI download type - table cell text") forKey:@"iPh_limited_sett_tk"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_test_client_type_sett_tk", nil, [NSBundle mainBundle], @"wf9-iphone-apps", @"Test client type - table cell text") forKey:@"iPh_test_client_type_sett_tk"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_prod_client_type_sett_tk", nil, [NSBundle mainBundle], @"wf9-iphone-vf", @"Production client type - table cell text") forKey:@"iPh_prod_client_type_sett_tk"];
	
	// page titles
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"[edit_detail]", nil, [NSBundle mainBundle], @"Edit detail", @"Headline in 'Edit detail' view") forKey:@"[edit_detail]"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"[prev_search_terms]", nil, [NSBundle mainBundle], @"Previous Terms", @"Headline in 'Search terms history list' view") forKey:@"[prev_search_terms]"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"[iPh_about_txt]", nil, [NSBundle mainBundle], @"About", @"Headline for 'About' view") forKey:@"[iPh_about_txt]"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_account_sett_txt", nil, [NSBundle mainBundle], @"Account", @"Headline in the 'Account' view") forKey:@"iPh_account_sett_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_categories_txt", nil, [NSBundle mainBundle], @"Categories", @"Headline in 'Categories' selection view") forKey:@"iPh_categories_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_country_txt", nil, [NSBundle mainBundle], @"Country", @"Headline in 'Country' selection view") forKey:@"iPh_country_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_countries_txt", nil, [NSBundle mainBundle], @"Country", @"Headline in 'Countries' selection view") forKey:@"iPh_countries_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_details_txt", nil, [NSBundle mainBundle], @"Details", @"Headline in the 'Details' view") forKey:@"iPh_details_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_edit_place_txt", nil, [NSBundle mainBundle], @"Edit place", @"Headline in the 'Details' view (edit mode)") forKey:@"iPh_edit_place_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_map_txt", nil, [NSBundle mainBundle], @"Map", @"Headline in 'Map' view") forKey:@"iPh_map_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_my_places_tk", nil, [NSBundle mainBundle], @"My places", @"Headline in 'My places' view") forKey:@"iPh_my_places_tk"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_navigate_to_txt", nil, [NSBundle mainBundle], @"Navigate to", @"'Headline in 'Navigate to' view") forKey:@"iPh_navigate_to_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_navigation_txt", nil, [NSBundle mainBundle], @"Navigation", @"Title in the main view") forKey:@"iPh_navigation_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_prev_searches_txt", nil, [NSBundle mainBundle], @"Previous searches", @"Headline in 'Search history list' view") forKey:@"iPh_prev_searches_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_route_optimisation_txt", nil, [NSBundle mainBundle], @"Route optimisation", @"Headline in 'Route Optimisation' view (in settings)") forKey:@"iPh_route_optimisation_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_route_overview_txt", nil, [NSBundle mainBundle], @"Route overview", @"Headline in 'Route overview' view") forKey:@"iPh_route_overview_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_search_results_txt", nil, [NSBundle mainBundle], @"Search results", @"Headline in 'Search results' view") forKey:@"iPh_search_results_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_search_txt", nil, [NSBundle mainBundle], @"Search", @"Headline in 'Search' view") forKey:@"iPh_search_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_settings_txt", nil, [NSBundle mainBundle], @"Settings", @"Headline in the 'Settings' view") forKey:@"iPh_settings_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_previous_txt", nil, [NSBundle mainBundle], @"Previous", @"Headline in the 'Previous Searches' view") forKey:@"iPh_previous_txt"];

	// measurements
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_seconds_txt", nil, [NSBundle mainBundle], @"sec", @"Abbreviation for seconds") forKey:@"iPh_seconds_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_minutes_txt", nil, [NSBundle mainBundle], @"min", @"Abbreviation for minutes") forKey:@"iPh_minutes_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_hours_txt", nil, [NSBundle mainBundle], @"h", @"Abbreviation for hours") forKey:@"iPh_hours_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_yards_txt", nil, [NSBundle mainBundle], @"yd", @"Abbreviation for yards") forKey:@"iPh_yards_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_miles_txt", nil, [NSBundle mainBundle], @"mi", @"Abbreviation for miles") forKey:@"iPh_miles_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_feet_txt", nil, [NSBundle mainBundle], @"ft", @"Abbreviation for feet") forKey:@"iPh_feet_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_metres_txt", nil, [NSBundle mainBundle], @"m", @"Abbreviation for meters") forKey:@"iPh_metres_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_kilometres_txt", nil, [NSBundle mainBundle], @"km", @"Abbreviation for kilometers") forKey:@"iPh_kilometres_txt"];
	
	// misc.
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"[my_position_on_map]", nil, [NSBundle mainBundle], @"My position", @"Headline in pop-up dialog displaying address of current position on map") forKey:@"[my_position_on_map]"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"[current_location_main_page]", nil, [NSBundle mainBundle], @"Determining current location...", @"Temporary text while waiting for reverse geocoding to display address on main page") forKey:@"[current_location_main_page]"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"[message_on_splash]", nil, [NSBundle mainBundle], @"Navigation can only be used by Vodafone UK customers.", @"Message on Vodafone splash screen, stating that only Vodafone customers can use the product") forKey:@"[message_on_splash]"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_around_me_txt", nil, [NSBundle mainBundle], @"Around me", @"Label for 'Around me' on/off toggle in search pages") forKey:@"iPh_around_me_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_fetching_data_txt", nil, [NSBundle mainBundle], @"Loading...", @"Text to show while waiting for server to deliver data via callback") forKey:@"iPh_fetching_data_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_no_descr_avail_txt", nil, [NSBundle mainBundle], @"No description available.", @"Place detail label when no description is available") forKey:@"iPh_no_descr_avail_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_no_details_avail_txt", nil, [NSBundle mainBundle], @"No details available", @"Place detail label when no details are available") forKey:@"iPh_no_details_avail_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_where_txt", nil, [NSBundle mainBundle], @"Where?", @"Label for 'where'-section on search page") forKey:@"iPh_where_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_name_txt", nil, [NSBundle mainBundle], @"Name", @"Title (specifying the name of the selected place - label on detail editing page)") forKey:@"iPh_name_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_description_txt", nil, [NSBundle mainBundle], @"Description", @"Title (specifying the description of the selected place - label on detail editing page)") forKey:@"iPh_description_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_most_recent_txt", nil, [NSBundle mainBundle], @"Most Recent", @"Country history 'most recent'-section label") forKey:@"iPh_most_recent_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_terms_conditions_txt", nil, [NSBundle mainBundle], @"Terms & Conditions", @"Terms & Conditions Label") forKey:@"iPh_terms_conditions_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_total_time_txt", nil, [NSBundle mainBundle], @"Total time:", @"Title (specifying the total time to route destination)") forKey:@"iPh_total_time_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_distance_txt", nil, [NSBundle mainBundle], @"Distance:", @"Title (specifying the total distance to route destination)") forKey:@"iPh_distance_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_time_left_txt", nil, [NSBundle mainBundle], @"Time left:", @"Title (specifying the remaining time to route destination)") forKey:@"iPh_time_left_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_distance_left_txt", nil, [NSBundle mainBundle], @"Distance left:", @"Title (specifying the remaining distance to route destination)") forKey:@"iPh_distance_left_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_from_txt", nil, [NSBundle mainBundle], @"From", @"From label title") forKey:@"iPh_from_txt"];
	[LOCALIZED_STRINGS setObject:NSLocalizedStringWithDefaultValue(@"iPh_to_txt", nil, [NSBundle mainBundle], @"To", @"To label title") forKey:@"iPh_to_txt"];
	
}

+ (NSString *)getString:(NSString *)identifier {
	NSString *ret = [LOCALIZED_STRINGS objectForKey:identifier];
	if (nil == ret) {
		ret = @"[undefined]";
	}
	return ret;
}

- (WFAPI::TextLanguage)getTextLanguage {
	NSString *textLang = [LocalizationHandler getString:@"WF_TEXT"];
	int num = [textLang intValue];
		
	return (WFAPI::TextLanguage)num;
}

- (WFAPI::VoiceLanguage::VoiceLanguage)getVoiceLanguage {
	NSString *voiceLang = [LocalizationHandler getString:@"WF_VOICE"];
	WFAPI::VoiceLanguage::VoiceLanguage num = (WFAPI::VoiceLanguage::VoiceLanguage)[voiceLang intValue];
	if (![self supportedVoiceLanguage:num]) num = WFAPI::VoiceLanguage::ENGLISH;
	return num;
}

+ (void)writeLanguageCodeFile {
	NSLog(@"Writing Language Code file to app Documents folder...");
	NSLocale *locale = [NSLocale autoupdatingCurrentLocale];
	NSLog(@"Current Language: %@", [locale displayNameForKey:NSLocaleLanguageCode value:[locale objectForKey:NSLocaleLanguageCode]]);
	NSLog(@"Current Country: %@", [locale displayNameForKey:NSLocaleCountryCode value:[locale objectForKey:NSLocaleCountryCode]]);
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"LanguageCodes.properties"];
	
	NSLog(@"Target file: %@", filePath);
	NSMutableDictionary *languages = [[NSMutableDictionary alloc] init];
	NSMutableArray *codes = [[NSMutableArray alloc] init];
	for (NSString *local in [NSLocale availableLocaleIdentifiers]) {
		NSLocale *loc = [[NSLocale alloc] initWithLocaleIdentifier:local];
		NSString *hat = [locale displayNameForKey:NSLocaleLanguageCode value:[loc objectForKey:NSLocaleLanguageCode]];
		[languages setObject:hat forKey:[loc objectForKey:NSLocaleLanguageCode]];
		if (![codes containsObject:[loc objectForKey:NSLocaleLanguageCode]]) {
			[codes addObject:[loc objectForKey:NSLocaleLanguageCode]];
		}
		[loc release];
	}
	FILE *fp;
	if ( ( fp = fopen([filePath cStringUsingEncoding:NSUTF8StringEncoding], "w" ) ) != NULL ) {
		for (NSString *lang in [codes sortedArrayUsingSelector:@selector(compare:)]) {
//			NSLog(@"%@ = %@", lang, [languages objectForKey:lang]);
			fprintf(fp, "%s=%s\n", [lang cStringUsingEncoding:NSUTF8StringEncoding], [[languages objectForKey:lang] cStringUsingEncoding:NSUTF8StringEncoding]);
		}
		fclose(fp);
		NSLog(@"Language Code file completed!");
	}
	else {
		NSLog(@"ERROR: could not write Language Code file...");
	}
	[languages release];
}

- (BOOL)supportedVoiceLanguage:(WFAPI::VoiceLanguage::VoiceLanguage)voiceLanguage {
	if ((WFAPI::VoiceLanguage::ENGLISH == voiceLanguage) ||
		(WFAPI::VoiceLanguage::GERMAN == voiceLanguage) ||
		(WFAPI::VoiceLanguage::ITALIAN == voiceLanguage) ||
		(WFAPI::VoiceLanguage::GREEK == voiceLanguage) ||
		(WFAPI::VoiceLanguage::SPANISH == voiceLanguage) ||
		(WFAPI::VoiceLanguage::DUTCH == voiceLanguage) ||
		(WFAPI::VoiceLanguage::PORTUGUESE == voiceLanguage) ||
		(WFAPI::VoiceLanguage::GERMAN == voiceLanguage)) {
		return YES;
	}
		
	return NO;
}

@end
