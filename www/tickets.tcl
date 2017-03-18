# contact-support/www/tickets.tcl


#customer-support/www/tickets
# This is the agenda page

# User may have subscribed tickets
# or tickets assocated with one or more customer.  Choose a customer, then view tickets.

# otherwise show new ticket form


#links to show open|closed tickets
# order by date or topic, search content for keyword/topic



# INPUTS / CONTROLLER

# set defaults

set title "#contact-support.tickets#"
set content_html ""

set instance_id [qc_set_instance_id]
set user_id [ad_conn user_id]
# basic permission check to allow more precise permission error messages
set read_p [permission::permission_p -party_id $user_id -object_id $instance_id -privilege read]

#qc_permission_p user_id contact_id property_label privilege instance_id 
#set read_p \[qc_permission_p $user_id $contact_id non_assets read $instance_id\]
#set create_p \[qc_permission_p $user_id $contact_id non_assets create $instance_id\]
#set write_p \[qc_permission_p $user_id $contact_id non_assets write $instance_id\]
#set admin_p \[qc_permission_p $user_id $contact_id non_assets admin $instance_id\]
#set delete_p \[qc_permission_p  $user_id $contact_id non_assets delete $instance_id\]

set user_message_list [list ]


set contact_ids_list [qc_contact_ids_for_user $user_id $instance_id]
set contact_ids_list_len [llength $contact_ids_list]
if { $contact_ids_list_len > 0 } {

    set form_posted [qf_get_inputs_as_array input_arr hash_check 1]
    qf_array_to_vars input_arr [list contact_id mode next_mode submit]
    
    if { $form_posted } {
        if { [info exists input_arr(x) ] } {
            unset input_arr(x)
        }
        if { [info exists input_arr(y) ] } {
            unset input_arr(y)
        }

        set validated_p 0
        # validate input
        if { [qf_is_natural_number $contact_id] && $contact_id in $contact_ids_list } {
            set contact_id_p 1
            set focus_contact_ids_list [list $contact_id]
        } else {
            set contact_id ""
            #contact_id_list already set
            set contact_id_p 0
            set focus_contact_ids_list $contact_ids_list
        }
        # else should default to 404 at switch in View section.
        
        # validate input values for specific modes
        # failovers for permissions follow reverse order (skipping ok): admin_p delete_p write_p create_p read_p
        # possibilities are: d, t, w, e, v, l, r, "" where "" is invalid input or unreconcilable error condition.
        # options include    d, l, r, t, e, "", w, v
        set http_header_method [ad_conn method]
        ns_log Notice "tickets.tcl(141): initial mode $mode, next_mode $next_mode, http_header_method ${http_header_method}"
        
        
        
        
    } else {
        # form not posted 
    }
    

    ns_log Notice "tickets.tcl(268): mode $mode next_mode $next_mode validated $validated_p"

    #
    # ACTIONS, PROCESSES / MODEL
    #



    if { $validated_p } {
        ns_log Notice "tickets.tcl ACTION mode $mode validated_p 1"
        # execute process using validated input
        # IF is used instead of SWITCH, so multiple sub-modes can be processed in a single mode.
        
    }
    
    
    set tickets_subscribed_list [cs_tickets_subscribed_to $user_id ]
    #field names: ticket_id instance_id contact_id authenticated_by ticket_category_id current_tier_level subject cs_open_p opened_by cs_time_opened cs_time_closed cs_closed_by user_open_p user_time_opened user_time_closed user_closed_by privacy_level trashed_p ignore_reopen_p unscheduled_service_req_p scheduled_maint_req_p priority 

    # full_tickets_list may be focused to one contact_id, or all
    set full_open_tickets_list [cs_tickets $focus_contact_ids_list]


    # sort primarily by contact_id:
    #if { !$contact_id_p } {
    #    set full_open_tickets_list \[lsort -index 2 -integer $full_open_tickets_list\]
    #}
    foreach c_id $focus_contact_ids_list {
        set user_roles_larr(${c_id}) [qc_roles_of_user_contact_id $user_id $c_id $instance_id]
        foreach $role_id $user_roles_larr(${c_id}) {
            set user_role_exists_p(${$c_id},${role_id}) 1
        }
    }

    # create new ticket_list_with_attributes
    set open_tickets_w_atts_list [list ]
    foreach fot $full_open_tickets_list {
        set c_id [lindex $fot 2]
        set category_id [lindex $fot 4]
        if { ![info exists prop_label(${category_id})] } {
            set property_label [cs_cat_cc_property_label $category_id]
        }
        if { ![info exists label_read_p(${c_id},${property_label}) ] } {
            set label_read_p(${c_id},${property_label}) [hf_perimission_p $user_id $c_id $property_label read $instance_id]
        }
        if { $label_read_p(${c_id},${property_label}) } {
            set fot_new $fot
            lappend fot_new $prop_label(${category_id})
            set tik_id [lindex $fot 0]
            if { $tik_id in $tickets_subscribed_list } {
                lappend fot_new "subscribed"
            } else {
                lappend fot_new "notsubscribed"
            }
            lappend open_tickets_w_atts_list $fot_new
        }

    }
    # Notes from requirements:
    # tickets shows tickets subscribed to not
    # list of tickets may be open only


    # Modes are views, or one of these compound action/views

    # Actions
    #  mode s = sort
    #       cronological
    #       reverse cronological
    #  mode w = bulk un/subscribe 

    # Views
    #  mode v = view, scope of 1 contact_id
    #  mode V = view, all contact_id, open tickets only


    set menu_list [list ]

    # OUTPUT / VIEW
    # using switch, because there's only one view at a time
    ns_log Notice "tickets.tcl(508): OUTPUT mode $mode"
    switch -exact -- $mode {
        l {
            #  list...... presents a list 
            if { $read_p } {
                if { $redirect_before_v_p } {
                    ns_log Notice "tickets.tcl(587): redirecting to url $url for clean url view"
                    ad_returnredirect "$url?mode=l"
                    ad_script_abort
                }

            }
        }
        w {
            # should already have been handled above
            ns_log Warning "tickets.tcl(575): mode = '${mode}' THIS SHOULD NOT BE CALLED."
            # it's called in validation section.
        }
        default {
            # return 404 not found or not validated (permission or other issue)
            if { [llength $user_message_list ] == 0 } {
                ns_returnnotfound
                # alternately:
                #  rp_internal_redirect /www/global/404.adp
                ad_script_abort
            }
        }
    }
    # end of switches

    set menu_html ""
    set validated_p_exists [info exists validated_p]
    if { $validated_p_exists && $validated_p || !$validated_p_exists } {
        foreach item_list $menu_list {
            set menu_label [lindex $item_list 0]
            set menu_url [lindex $item_list 1]
            append menu_html "<a href=\"${menu_url}\" title=\"${menu_label}\">${menu_label}</a> &nbsp; "
        }
    } 




} else {
    set content_html "<p><strong>#q-control.You_don_t_have_permission#</strong></p>\n"
    append content_html "<p>#q-control.You_have_not_been_assigned_to_a_contact#</p>"
}

set context [list $title]
