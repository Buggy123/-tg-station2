 /**
  * NanoUI Subsystem
  *
  * Contains all NanoUI state and subsystem code.
  *
  * /tg/station user interface library
  * thanks to baystation12
  *
  * modified by neersighted
 **/

 /**
  * public
  *
  * Get a open NanoUI given a user, src_object, and ui_key and try to update it with data.
  *
  * required user mob The mob who opened/is using the NanoUI.
  * required src_object atom/movable The object which owns the NanoUI.
  * required ui_key string The ui_key of the NanoUI.
  * optional ui datum/nanoui The UI to be updated, if it exists.
  * optional data list The data to update the UI with, if it exists.
  * optional force_open bool If the UI should be re-opened instead of updated.
  *
  * return datum/nanoui The found NanoUI.
 **/
/datum/subsystem/nano/proc/try_update_ui(mob/user, atom/movable/src_object, ui_key, datum/nanoui/ui, \
											list/data = null, force_open = 0)
	if (!data)
		data = src_object.get_ui_data(user)

	if (isnull(ui)) // No NanoUI was passed, so look for one.
		ui = get_open_ui(user, src_object, ui_key)

	if (!isnull(ui))
		if (!force_open) // UI is already open; update it.
			ui.push_data(data)
		else // Re-open it anyways.
			ui.reinitialise(null, data)
		return ui // We found the UI, return it.
	else
		return null // We couldn't find a UI.
 /**
  * public
  *
  * Get a open NanoUI given a user, src_object, and ui_key.
  *
  * required user mob The mob who opened/is using the NanoUI.
  * required src_object atom/movable The object which owns the NanoUI.
  * required ui_key string The ui_key of the NanoUI.
  *
  * return datum/nanoui The found NanoUI.
 **/
/datum/subsystem/nano/proc/get_open_ui(mob/user, atom/movable/src_object, ui_key)
	var/src_object_key = "\ref[src_object]"
	if (isnull(open_uis[src_object_key]) || !istype(open_uis[src_object_key], /list))
		return null // No UIs open.
	else if (isnull(open_uis[src_object_key][ui_key]) || !istype(open_uis[src_object_key][ui_key], /list))
		return null // No UIs open for this object.

	for (var/datum/nanoui/ui in open_uis[src_object_key][ui_key]) // Find UIs for this object.
		if (ui.user == user) // Make sure we have the right user
			return ui

	return null // Couldn't find a UI!

 /**
  * public
  *
  * Update all NanoUIs attached to src_object.
  *
  * required src_object atom/movable The object which owns the NanoUIs.
  *
  * return int The number of NanoUIs updated.
 **/
/datum/subsystem/nano/proc/update_uis(atom/movable/src_object)
	var/src_object_key = "\ref[src_object]"
	if (isnull(open_uis[src_object_key]) || !istype(open_uis[src_object_key], /list))
		return 0 // Couldn't find any UIs for this object.

	var/update_count = 0
	for (var/ui_key in open_uis[src_object_key])
		for (var/datum/nanoui/ui in open_uis[src_object_key][ui_key])
			if(ui && ui.src_object && ui.user && ui.src_object.nano_host()) // Check the UI is valid.
				ui.process(update = 1) // Update the UI.
				update_count++ // Count each UI we update.
	return update_count

 /**
  * public
  *
  * Close all NanoUIs attached to src_object.
  *
  * required src_object atom/movable The object which owns the NanoUIs.
  *
  * return int The number of NanoUIs closed.
 **/
/datum/subsystem/nano/proc/close_uis(atom/movable/src_object)
	var/src_object_key = "\ref[src_object]"
	if (isnull(open_uis[src_object_key]) || !istype(open_uis[src_object_key], /list))
		return 0 // Couldn't find any UIs for this object.

	var/close_count = 0
	for (var/ui_key in open_uis[src_object_key])
		for (var/datum/nanoui/ui in open_uis[src_object_key][ui_key])
			if(ui && ui.src_object && ui.user && ui.src_object.nano_host()) // Check the UI is valid.
				ui.close() // Close the UI
				close_count++ // Count each UI we close.
	return close_count

 /**
  * public
  *
  * Update all NanoUIs belonging to a user.
  *
  * required user mob The mob who opened/is using the NanoUI.
  * optional src_object atom/movable If provided, only update UIs belonging this atom.
  * optional ui_key string If provided, only update UIs with this UI key.
  *
  * return int The number of NanoUIs updated.
 **/
/datum/subsystem/nano/proc/update_user_uis(mob/user, atom/movable/src_object = null, ui_key = null)
	if (isnull(user.open_uis) || !istype(user.open_uis, /list) || open_uis.len == 0)
		return 0 // Couldn't find any UIs for this user.

	var/update_count = 0
	for (var/datum/nanoui/ui in user.open_uis)
		if ((isnull(src_object) || !isnull(src_object) && ui.src_object == src_object) && (isnull(ui_key) || !isnull(ui_key) && ui.ui_key == ui_key))
			ui.process(update = 1) // Update the UI.
			update_count++ // Count each UI we upadte.
	return update_count

 /**
  * public
  *
  * Close all NanoUIs belonging to a user.
  *
  * required user mob The mob who opened/is using the NanoUI.
  * optional src_object atom/movable If provided, only update UIs belonging this atom.
  * optional ui_key string If provided, only update UIs with this UI key.
  *
  * return int The number of NanoUIs closed.
 **/
/datum/subsystem/nano/proc/close_user_uis(mob/user, atom/movable/src_object = null, ui_key = null)
	if (isnull(user.open_uis) || !istype(user.open_uis, /list) || open_uis.len == 0)
		return 0 // Couldn't find any UIs for this user.

	var/close_count = 0
	for (var/datum/nanoui/ui in user.open_uis)
		if ((isnull(src_object) || !isnull(src_object) && ui.src_object == src_object) && (isnull(ui_key) || !isnull(ui_key) && ui.ui_key == ui_key))
			ui.close() // Close the UI.
			close_count++ // Count each UI we close.
	return close_count

 /**
  * private
  *
  * Add a NanoUI to the list of open UIs.
  *
  * required ui datum/nanoui The UI to be added.
 **/
/datum/subsystem/nano/proc/ui_opened(datum/nanoui/ui)
	var/src_object_key = "\ref[ui.src_object]"
	if (isnull(open_uis[src_object_key]) || !istype(open_uis[src_object_key], /list))
		open_uis[src_object_key] = list(ui.ui_key = list()) // Make a list for the ui_key and src_object.
	else if (isnull(open_uis[src_object_key][ui.ui_key]) || !istype(open_uis[src_object_key][ui.ui_key], /list))
		open_uis[src_object_key][ui.ui_key] = list() // Make a list for the ui_key.

	// Append the UI to all the lists.
	ui.user.open_uis |= ui
	var/list/uis = open_uis[src_object_key][ui.ui_key]
	uis |= ui
	processing_uis |= ui

 /**
  * private
  *
  * Remove a NanoUI from the list of open UIs.
  *
  * required ui datum/nanoui The UI to be removed.
  *
  * return bool If the UI was removed or not.
 **/
/datum/subsystem/nano/proc/ui_closed(datum/nanoui/ui)
	var/src_object_key = "\ref[ui.src_object]"
	if (isnull(open_uis[src_object_key]) || !istype(open_uis[src_object_key], /list))
		return 0 // It wasn't open.
	else if (isnull(open_uis[src_object_key][ui.ui_key]) || !istype(open_uis[src_object_key][ui.ui_key], /list))
		return 0 // It wasn't open.

	processing_uis.Remove(ui) // Remove it from the list of processing UIs.
	if(ui.user)	// If the user exists, remove it from them too.
		ui.user.open_uis.Remove(ui)
	var/list/uis = open_uis[src_object_key][ui.ui_key] // Remove it from the list of open UIs.
	uis.Remove(ui)
	return 1 // Let the caller know we did it.

 /**
  * private
  *
  * Handle client logout, by closing all their NanoUIs.
  *
  * required user mob The mob which logged out.
  *
  * return int The number of NanoUIs closed.
 **/
/datum/subsystem/nano/proc/user_logout(mob/user)
	return close_user_uis(user)

 /**
  * private
  *
  * Handle clients switching mobs, by transfering their NanoUIs.
  *
  * required user oldMob The client's original mob.
  * required user newMob The client's new mob.
  *
  * return bool If the NanoUIs were transferred.
 **/
/datum/subsystem/nano/proc/user_transferred(mob/oldMob, mob/newMob)
	if (!oldMob || isnull(oldMob.open_uis) || !istype(oldMob.open_uis, /list) || open_uis.len == 0)
		return 0 // The old mob had no open NanoUIs.

	if (isnull(newMob.open_uis) || !istype(newMob.open_uis, /list))
		newMob.open_uis = list() // Create a list for the new mob if needed.

	for (var/datum/nanoui/ui in oldMob.open_uis)
		ui.user = newMob // Inform the UIs of their new owner.
		newMob.open_uis.Add(ui) // Transfer all the NanoUIs.

	oldMob.open_uis.Cut() // Clear the old list.
	return 1 // Let the caller know we did it.

 /**
  * public
  *
  * Generate the list of resources to be sent to clients.
  * fcopy the resources to make them available as rscs.
  *
  * return list The resource files.
 **/
/datum/subsystem/nano/proc/get_resources()
	var/list/resources = list()
	// A list of folders to be sent.
	var/list/resource_dirs = list(\
		"nano/css/",\
		"nano/images/",\
		"nano/js/",\
		"nano/templates/"\
	)

	// Crawl the directories to find files.
	for (var/path in resource_dirs)
		var/list/filenames = flist(path)
		for(var/filename in filenames)
			if(copytext(filename, length(filename)) != "/") // Ignore directories.
				if(fexists(path + filename))
					resources[filename] = fcopy_rsc(path + filename)

	return resources

 /**
  * public
  *
  * Send a list of resource files to the client.
  * Use the asset_cache system by default.
  *
  * required client The client recieving the resources.
  * optional resources The resources to be sent.
  * optional force Bypass the asset_cache system to force a redownload.
 **/
/datum/subsystem/nano/proc/send_resources(client/client, list/resources = resource_files, force = 0)
	if (force)
		for(var/resource in resources)
			client << browse_rsc(resources[resource])
	else
		getFilesSlow(client, resources)
