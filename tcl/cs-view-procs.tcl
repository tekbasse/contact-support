#contact-support/tcl/cs-view-procs.tcl
ad_library {

    views for contact-support
    @creation-date 21 Jan 2017
    @Copyright (c) 2017 Benjamin Brink
    @license GNU General Public License 2
    @project home: http://github.com/tekbasse/contact-support
    @address: po box 20, Marylhurst, OR 97036-0020 usa
    @email: tekbasse@yahoo.com
    
}


ad_proc -private cs_contact_reps_of_cat {
    args
} {
    Returns user_ids of arg: contact_id that are associate with category as a list.
    <br/>
    contact_id is contact's contact_id from qal_contacts.
    <br/>
    <code>args</code> can be passed as name value list. Minimum required is contact_id and a category reference:
    <br/>
    Accepted cs_categories.names are: <code>category_id</code>, <code>parent_id</code>, and <code>label</code>.
    <br/>
    Privilege is one of read,write,create,delete,admin. Default is write.
    <br/>
    If there is an error, an empty list is returned.
} {
    upvar 1 instance_id instance_id
    # cs_contact_reps_of_cat and cs_support_reps_of_cat are separate, because
    # this is a place where one or the other may be modified,
    # and modification becomes more difficult if these use a single call point.
    set user_ids_list [list ]
    set assigned_uids_list [list ]
    set privilege "write"
    qf_nv_list_to_vars $args [list category_id parent_id label contact_id privilege]

    # if category_id not avail, try parent_id as cateogry_id
    # if that is not avail, try label.
    if { ![qf_is_natural_number $category_id] } {
        if { [qf_is_natural_number $parent_id ] } {
            set cat_id $parent_id
        } elseif { $label ne "" } {
            set cat_id [cs_cat_id_of_label $label]
        }
    } else {
        set cat_id $category_id
    }
    if { $cat_id ne "" } {
        set property_label [cs_cat_cc_property_label $cat_id]
        
        if { $property_label ne "" } {
            # convert to property_id
            set property_id [qc_property_id $property_label $instance_id]
            
            if { $property_id ne "" } {
                set role_ids_list [qc_roles_of_prop_priv $property_id $privilege]
                
                if { [llength $role_ids_list] > 0 } {
                    # get user_ids limited by hf_role_id in one query
                    set user_ids_list [qc_user_ids_of_contact_id $contact_id $role_ids_list]
                } else {
                    ns_log Notice "cs_contact_reps_of_cat: property_id '${property_id}' privilege '${privilege}'. no role_id found."

                }
            } else {
                ns_log Notice "cs_contact_reps_of_cat: property_label '${property_label}' not found. property_id is blank."
            }
        } else {
            ns_log Notice "cs_contact_reps_of_cat: cat_id '${cat_id}' not found. property_label is blank."
        }
    } else {
        ns_log Notice "cs_contact_reps_of_cat: category_id not found. category_id '${category_id} parent_id '${parent_id}' category label '${label}'"
    }
    # add user_ids from cs_cat_assignment_map
    set cc_uids_list [db_list cs_contact_rep_cat_map_read {select user_id from cs_contact_rep_cat_map 
        where category_id=:category_id 
        and instance_id=:instance_id}]
    set assigned_uids_list [set_union $user_ids_list $cc_uids_list]
    return $assigned_uids_list
}


ad_proc -private cs_support_reps_of_cat {
    args
} {
    Returns user_ids of args.
    <br/>
    <code>args</code> can be passed as name value list. Minimum required is contact_id and a category reference:
    <br/>
    Accepted cs_categories.names are: <code>category_id</code>, <code>parent_id</code>, and <code>label</code>.
    <br/>
    Privilege is one of read,write,create,delete,admin. Default is write.
    <br/>
    <code>contact_id</code> is instance_id by default, but can be specified.
    <br/>
    If there is an error, an empty list is returned.
} {
    upvar 1 instance_id instance_id
    # cs_contact_reps_of_cat and cs_support_reps_of_cat are separate, because
    # this is a place where one or the other may be modified,
    # and modification becomes more difficult if these use a single call point.
    set user_ids_list [list ]
    set assigned_uids_list [list ]
    set privilege "write"
    set contact_id $instance_id
    qf_nv_list_to_vars $args [list category_id parent_id label contact_id privilege]

    # if category_id not avail, try parent_id as cateogry_id
    # if that is not avail, try label.
    if { ![qf_is_natural_number $category_id] } {
        if { [qf_is_natural_number $parent_id ] } {
            set cat_id $parent_id
        } elseif { $label ne "" } {
            set cat_id [cs_cat_id_of_label $label]
        }
    } else {
        set cat_id $category_id
    }
    if { $cat_id ne "" } {
        set property_label [cs_cat_cc_property_label $cat_id]
        
        if { $property_label ne "" } {
            # convert to property_id
            set property_id [qc_property_id $property_label $instance_id]
            
            if { $property_id ne "" } {
                set role_ids_list [qc_roles_of_prop_priv $property_id $privilege]
                
                if { [llength $role_ids_list] > 0 } {
                    # get user_ids limited by hf_role_id in one query
                    set user_ids_list [qc_user_ids_of_contact_id $contact_id $role_ids_list]
                } else {
                    ns_log Notice "cs_support_reps_of_cat: property_id '${property_id}' privilege '${privilege}'. no role_id found."
                }
            } else {
                ns_log Notice "cs_support_reps_of_cat: property_label '${property_label}' not found. property_id is blank."
            }
        } else {
            ns_log Notice "cs_support_reps_of_cat: cat_id '${cat_id}' not found. property_label is blank."
        }
    } else {
        ns_log Notice "cs_support_reps_of_cat: category_id not found. category_id '${category_id} parent_id '${parent_id}' category label '${label}'"
    }
    # add user_ids from cs_support_rep_cat_map
    set cc_uids_list [db_list cs_support_rep_cat_map_read {select user_id from cs_support_rep_cat_map 
        where category_id=:category_id 
        and instance_id=:instance_id}]
    set assigned_uids_list [set_union $user_ids_list $cc_uids_list]
    return $assigned_uids_list
}


ad_proc -private cs_cat_cs_property_label {
    category_id
} {
    Returns property_label associated with a category for support reps, or empty string if not available.
} {
    upvar 1 instance_id instance_id
    set cs_property_label ""
    db_0or1row cs_categories_r_cspl {select cs_property_label from cs_categories 
        where id=:category_id
        and instance_id=:instance_id
        and active_p!='0'
    }
    return $cs_property_label
}

ad_proc -private cs_cat_cc_property_label {
    category_id
} {
    Returns property_label associated with a category for contact reps.
} {
    upvar 1 instance_id instance_id
    set cc_property_label ""
    db_0or1row cs_categories_r_cspl {select cc_property_label from cs_categories 
        where id=:category_id
        and instance_id=:instance_id
        and active_p!='0'
    }
    return $cc_property_label
}

ad_proc -private cs_tickets_assigned_to {
    {user_id ""}
} {
    Lists ticket_ids for a support rep of user_id as a list.
} {
    upvar 1 instance_id instance_id
    # cs_tickets
    set id_list [db_list cs_support_rep_ticket_map {select ticket_id from cs_support_rep_ticket_map
        where user_id=:user_id
        and instance_id=:instance_id} ]
    return $id_list
}

ad_proc -private cs_tickets_subscribed_to {
    {user_id ""}
} {
    Lists ticket_ids for a contact rep user_id as a list.
} {
    upvar 1 instance_id instance_id
    # cs_tickets
    set id_list [db_list cs_contact_rep_ticket_map {select ticket_id from cs_contact_rep_ticket_map
        where user_id=:user_id
        and instance_id=:instance_id} ]
    return $id_list
}

ad_proc -private cs_est_contact_response_time {
    contact_id
    {pretty_p "1"}
} {
    Returns anticipated contact response time (median) in human readable format, or empty string if not enough info.
    Currently only calcuates response times based on tickets requesting responses regarding scheduled operations.
    If pretty_p is 0, the response time is return in integer seconds units.
} {
    upvar 1 instance_id instance_id
    # Maybe later make a proc that returns a cobbler list, fixed system time vs. historical probability
    # aka cs_anticipated_contact_response_time
    set fr_s_list [db_list cs_ticket_stats_ecr {select cs_first_response_s from cs_ticket_stats
        where instance_id=:instance_id
        and ticket_id in (select ticket_id from cs_tickets
                          where contact_id=:contact_id
                          and ( scheduled_operation_p='1' or scheduled_maint_req_p='1' )
                          and instance_id=:instance_id ) } ]
    set ecr_time [cs_median_human_time $fr_s_list $pretty_p]

    return $ecr_time
}

# The following will be called in lib as includes, but
# also maybe in cron monitoring procs, which is why these are procs:

ad_proc -private cs_stats_ticket_response {
    {pretty_p "1"}
} {
    Returns estimated time for ticket response from support (for nonscheduled events).
    If pretty_p is "0", value is returned in integer seconds.
} {
    upvar 1 instance_id instance_id
    # cs_stats_til_ticket_response (only for nonscheduled events)
    # esr = estimated support response time
    set fr_s_list [db_list cs_ticket_stats_esr {select cs_first_response_s from cs_ticket_stats
        where instance_id=:instance_id } ]
    set esr_time [cs_median_human_time $fr_s_list $pretty_p]
    return $esr_time
}

ad_proc -private cs_stats_ticket_close {
    {pretty_p "1"}
} {
    Returns estimated time for ticket resolution (for nonscheduled events).
    If pretty_p is "0", returns value in integer seconds.
} {
    upvar 1 instance_id instance_id
    # cs_stats_til_ticket_close (only for nonscheduled_events)
    # etr = estimated time until resolution
    set fr_s_list [db_list cs_ticket_stats_etr {select cs_final_response_s from cs_ticket_stats
        where instance_id=:instance_id } ]
    set etr_time [cs_median_human_time $fr_s_list $pretty_p]
    return $etr_time
}

   
ad_proc -private cs_ticket_read {
    ticket_id
} {
    Reads a record from cs_tickets. Returns a name value list.
} {
    upvar 1 instance_id instance_id

    set v_list_of_lists [db_list_of_lists cs_tickets_r1 { select ticket_id,instance_id,contact_id,
        authenticated_by,ticket_category_id,current_tier_level,subject,
        cs_open_p,opened_by,cs_time_opened,cs_time_closed,cs_closed_by,
        user_open_p,user_time_opened,user_time_closed,user_closed_by,
        privacy_level,trashed_p,ignore_reopen_p,unscheduled_service_req_p,
        scheduled_maint_req_p,priority
        from cs_tickets
        where instance_id=:instance_id
        and ticket_id=:ticket_id}]
    set nv_list [list ]    
    if { $v_list_of_lists ne $nv_list } {
        set keys [list ticket_id \
                      instance_id \
                      contact_id \
                      authenticated_by \
                      ticket_category_id \
                      current_tier_level \
                      subject \
                      cs_open_p \
                      opened_by \
                      cs_time_opened \
                      cs_time_closed \
                      cs_closed_by \
                      user_open_p \
                      user_time_opened \
                      user_time_closed \
                      user_closed_by \
                      privacy_level \
                      trashed_p \
                      ignore_reopen_p \
                      unscheduled_service_req_p \
                      scheduled_maint_req_p \
                      priority]
        
        set v_list [lindex $v_lists_of_lists 0]
        set i 0
        foreach key $keys {
            lappend nv_list $key [lindex $v_list $i]
            incr i
        }
    }
    return $nv_list
}

ad_proc -private cs_announcement_ids {
} {
    Returns a list of unique contact-support announcement_id(s) for user_id and their contacts.
} {
    upvar 1 instance_id instance_id
    set user_id [ad_conn user_id]
    set contact_id_list [qal_contact_ids_of_user_id $user_id]
    set ann_list [db_list cs_ann_user_contact_map_id_list "select ann_id from cs_ann_user_contact_map \
        where ( user_id=:user_id or contact_id in ([template::util::tcl_to_sql_list ${contact_id_list} ]) ) \
        and instance_id=:instance_id \
        and trashed_p!='1'"]
    if { [llength $ann_list] > 1 } {
        set ann_ids_list [qf_uniques_of $ann_list]
    } else {
        set ann_ids_list $ann_list
    }
    return $ann_ids_list
}


ad_proc -private cs_announcements {
    ann_id_list
} {
    Returns a list of ordered lists of contact-support announcments relevant to annnouncement ids (ann_id_list) and user_id.
    <br/>
    ordered fields: id ann_type ticket_id start_timestamp expire_timestamp expired_p annoucement
    <br/>
    If there are no announcements, returns an empty list.
} {
    upvar 1 instance_id instance_id
    set announcements_lists [db_list_of_lists cs_announcements_list "select id,ann_type, \
 ticket_id,start_timestamp,expire_timestamp,expired_p,allow_html_p,announcement from cs_announcements \
 where ( now() > start_timestamp or start_timestamp is null) and expired_p!='1' and \
 id in ([template::util::tcl_to_sql_list ${ann_id_list} ])"]
    return $announcements_lists
}

ad_proc -private cs_announcements_agenda {
    {property_label "non_assets"}
} {
    Returns a list of ordered lists of all unexpired and future contact-support announcments 
    <br/>
    ordered fields: id ann_type ticket_id start_timestamp expire_timestamp expired_p allow_html_p announcement
    <br/>
    If there are no announcements, returns an empty list.
    <br/>
    Must have qc_permission write permissions on property_label (non_assets).
} {
    upvar 1 instance_id instance_id
    set user_id [ad_conn user_id]
    set write_p [qc_permission_p $user_id $instance_id $property_label write $instance_id]
    if { $write_p } {
        set announcements_lists [db_list_of_lists cs_announcements_list_all {select id,ann_type, 
            ticket_id,start_timestamp,expire_timestamp,expired_p,allow_html_p,announcement from cs_announcements 
            where ( now() > start_timestamp or start_timestamp is null) and expired_p!='1' }]
    } else {
        set announcements_lists [list ]
        ns_log Notice "cs_announcemenets_agenda.375: access denied. user_id '${user_id}' package_id '${package_id}'"
    }
    return $announcements_lists
}
