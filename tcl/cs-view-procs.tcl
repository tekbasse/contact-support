#customer-service/tcl/cs-view-procs.tcl
ad_library {

    views for customer-service
    @creation-date 21 Jan 2017
    @Copyright (c) 2017 Benjamin Brink
    @license GNU General Public License 2
    @project home: http://github.com/tekbasse/customer-service
    @address: po box 20, Marylhurst, OR 97036-0020 usa
    @email: tekbasse@yahoo.com
    
}


ad_proc -private cs_reps_of_cat {
    args
} {
    Returns user_ids of contact_id that are associate with category as a list.
    <br/>
    For customer reps, contact_id is customer's contact_id from qal_contacts.
    <br/>
    For support reps, contact_id is instance_id from qc_set_instance_id
    <br/>
    <code>args</code> can be passed as name value list or left empty for all cases.
    <br>
    Accepted names are: <code>category_id</code>, <code>parent_id</code>, and <code>label</code>.
    <br>
} {
    upvar 1 instance_id instance_id
    ##code
    # read cs_categories.property_label
    # convert to property_id
    set property_id [qc_property_id $property_label $instance_id]

    if { $property_id ne "" } {
        set role_ids_list [qc_roles_of_prop_priv $property_id $privilege]

    } 

    if { [llength $role_ids_list] > 0 } {
        # get user_ids limited by hf_role_id in one query
        set user_ids_list [qc_user_ids_of_contact_id $contact_id $role_ids_list]
    }
    # add user_ids from cs_cat_assignment_map

}


ad_proc -private cs_cat_role_map_read {
    args
} {
    Returns one roles associated with a category as a tcl list of lists.
    
    <br/>
    <code>args</code> can be passed as name value list or left empty for all cases.
    <br>
    Accepted names are: <code>category_id</code>, <code>parent_id</code>, and <code>label</code>.
    <br>
} {
    upvar 1 instance_id instance_id
    ##code

}

ad_proc -private cs_tickets {
    {user_id ""}
} {
    Lists tickets for user_id.
} {
    upvar 1 instance_id instance_id
    # cs_tickets
    ##code
}

ad_proc -private cs_est_customer_response_time {
} {
    Returns anticipated customer response time as a cobbler list, fixed system time vs. historical probability
} {
    upvar 1 instance_id instance_id
    # cs_anticipated_customer_response_time
    ##code


}

# The following will be called in lib as includes, but
# also maybe in cron monitoring procs, which is why these are procs:

ad_proc -private cs_stats_ticket_response {
} {
    Returns estimated time for ticket response (for nonscheduled events).
} {
    upvar 1 instance_id instance_id
    # cs_stats_til_ticket_response (only for nonscheduled events)
    ##code
}

ad_proc -private cs_stats_ticket_close {
} {
    Returns estimated time for ticket resolution (for nonscheduled events).
} {
    upvar 1 instance_id instance_id
    # cs_stats_til_ticket_close (only for nonscheduled_events)
    ##code

}
