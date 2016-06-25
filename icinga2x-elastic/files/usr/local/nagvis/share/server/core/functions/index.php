<?php
/*******************************************************************************
 *
 * index.php - This file is included by the single index files in NagVis to
 *             consolidate equal code
 *
 * Copyright (c) 2004-2015 NagVis Project (Contact: info@nagvis.org)
 *
 * License:
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 ******************************************************************************/
/*
Icinga Web 2 integration
*/
use Icinga\Application\EmbeddedWeb;

set_include_path('/usr/share/icingaweb2/library/vendor:/usr/share/icingaweb2/library:' . get_include_path());
require_once 'Icinga/Application/EmbeddedWeb.php';
require_once EmbeddedWeb::start(null, '/etc/icingaweb2')

    ->getModuleManager()
    ->getModule('nagvis')
    ->getLibDir() . '/nagvis-includes/init.inc.php';

/*
* Url: Parse the url to know later what module and
*      action is called. The requested uri is splitted
*      into elements for later usage.
*/

$UHANDLER = new CoreUriHandler();

/*
* Session: Handle the user session
*/

$SHANDLER = new CoreSessionHandler();

/*
 * Authentication: Try to authenticate the user
 */

$AUTH = new CoreAuthHandler();

// Session: Logged in?
// -> Get credentials from session and check auth
if(!($AUTH->sessionAuthPresent() && $AUTH->isAuthenticatedSession())) {
    // ...otherwise try to auth the user
    // Logon Module?
    // -> Received data to check the auth? Then check auth!
    // -> Save to session if logon module told to do so!
    $logonModule = 'Core' . cfg('global', 'logonmodule');
    $logonModule = $logonModule == 'CoreLogonDialog' ? 'CoreLogonDialogHandler' : $logonModule;
    $MODULE = new $logonModule($CORE);
    $ret = $MODULE->check();
    // Maybe handle other module now
    if(is_array($ret)) {
        $UHANDLER->set('mod', $ret[0]);
        $UHANDLER->set('act', $ret[1]);
        $LOGIN_MSG = $ret[2];
    }
}

/*
* Authorisation 1: Collect and save the permissions when the user is logged in
*                  and nothing other is saved yet
*/

if($AUTH->isAuthenticated()) {
    $AUTHORISATION = new CoreAuthorisationHandler();
    $AUTHORISATION->parsePermissions();
} else
    $AUTHORISATION = null;

// Make the AA information available to whole NagVis for permission checks
$CORE->setAA($AUTH, $AUTHORISATION);

// Re-set the language to handle the user individual language
$_LANG->setLanguage(HANDLE_USERCFG);

/*
* Module handling 1: Choose modules
*/

// Register valid modules
// Unregistered modules can not be accessed
foreach($_modules AS $mod)
    $MHANDLER->regModule($mod);

// Load the module
$MODULE = $MHANDLER->loadModule($UHANDLER->get('mod'));
if($MODULE == null)
    throw new NagVisException(l('The module [MOD] is not known',
                             Array('MOD' => htmlentities($UHANDLER->get('mod'), ENT_COMPAT, 'UTF-8'))));
$MODULE->setAction($UHANDLER->get('act'));
$MODULE->initObject();

/*
* Authorisation 2: Check if the user is permitted to use this module/action
*                  If not redirect to Msg/401 (Unauthorized) page
*/

// Only check the permissions for modules which require an authorization.
// For example the info page and the login page don't need a special authorization
if($MODULE->actionRequiresAuthorisation())
    $MODULE->isPermitted();

/*
* Module handling 2: Render the modules when permitted
*                    otherwise handle other pages
*/

// Handle regular action when everything is ok
// When no matching module or action is found show the 404 error
if($MODULE !== false && $MODULE->offersAction($UHANDLER->get('act'))) {
    $MODULE->setAction($UHANDLER->get('act'));

    // Handle the given action in the module
    $sContent = $MODULE->handleAction();
} else {
    // Create instance of msg module
    throw new NagVisException(l('The given action is not valid'));
}

echo $sContent;
if (DEBUG&&DEBUGLEVEL&4) debugFinalize();
if (PROFILE) profilingFinalize($_name.'-'.$UHANDLER->get('mod').'-'.$UHANDLER->get('act'));

exit(0);

?>
