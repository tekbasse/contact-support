#customer-service/tcl/customer-service-procs.tcl
ad_library {

    misc API for customer-service
    @creation-date 22 May 2016
    @Copyright (c) 2016 Benjamin Brink
    @license GNU General Public License 3, see project home or http://www.gnu.org/licenses/gpl-3.0.en.html
    @project home: http://github.com/tekbasse/customer-service
    @address: po box 20, Marylhurst, OR 97036-0020 usa
    @email: tekbasse@yahoo.com
    
}

# following are to be custom defined
# cs_customer_ids_for_user

ad_proc -private cs_customer_ids_for_user { 
    {user_id ""}
    {instance_id ""}
    {closed_p "0"}
} {
    Returns list of customer_id available to user_id. If closed_p is 1, returns closed tickets also.
} {
    if { $instance_id eq "" } {
        # set instance_id package_id
        set instance_id [qc_set_instance_id]
    }
    if { $user_id eq "" } {
        set user_id [ad_conn user_id]
    }
    # Change this following line to whatever other package reference provides a list of customer_ids for user_id
    # Use accounts-ledger api for default, consider a package parameter for other cases
    ## code
    set customer_id_list [list $user_id]
    return $customer_id_list
}

## After multiple reps have been alerted, 
# There needs to be some way to assign 1+ to a ticket so that
# work is not duplicated or uncoordinated.
# This can be done by changing CS rep assignments in ticket. 
# If a CS rep assigns another role, then current subcribers are unsubscribed, and new roles subscribed and notified.
# Person accepts assignment ie says actively working on it by posting (and optinally removing other CS reps from subscription list based on package parameter VolunteerUnsubscribesOthersP).
# This should be push button easy.
# if an unassigned person goes to page, they can add themselves by button, but not unsubscribe others.

# tickets can be created, updated (opened, closed), trashed, listed, read
# messages can be created, read, trashed, not updated (edited), viewed by customer or CS reps or both
# notifications sent to cs reps and/or customers
# users can unsubscribe
# customer reps can edit subscription list by changing cs subscribers to a new group or tier
# a proc to create a message and ticket url 
# ticket shows a ticket, 
# tickets shows tickets subscribed to or open or closed
# subscriptions shows open ticket subscriptions
# admin/tiers show/edit tier levels.  Default tier also performs triage.
# admin/categories-tiers show/edit roles assigned to each category/tier
#    presented in table format using checkboxes, tiers vs. categories?
#    No. each tier&category gets associated with one or more roles. Present as 
#    a list of role choices for each permuation of tier/category
# admin/categories show/edit categories

