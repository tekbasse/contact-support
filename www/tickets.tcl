# contact-support/www/tickets.tcl


# INPUTS / CONTROLLER

# set defaults

set title "#contact-support.Contact_Serivce# #contact-support.tickets#"

set instance_id [qc_set_instance_id]
set user_id [ad_conn user_id]
#qc_permission_p user_id contact_id property_label privilege instance_id 
set read_p [qc_permission_p $user_id $contact_id non_assets read $instance_id]
set create_p [qc_permission_p $user_id $contact_id non_assets create $instance_id]
set write_p [qc_permission_p $user_id $contact_id non_assets write $instance_id]
set admin_p [qc_permission_p $user_id $contact_id non_assets admin $instance_id]
set delete_p [qc_permission_p  $user_id $contact_id non_assets delete $instance_id]

set user_message_list [list ]

set form_posted [qf_get_inputs_as_array input_arr hash_check 1]

qf_array_to_vars input_arr [list contact_id ticket_id mode next_mode submit]

ns_log Notice "tickets.tcl(63): mode $mode next_mode $next_mode"

# Notes from requirements:
# tickets shows tickets subscribed to or open or closed


# Modes are views, or one of these compound action/views

# Actions

# Views

if { $form_posted } {
    if { [info exists input_arr(x) ] } {
        unset input_arr(x)
    }
    if { [info exists input_arr(y) ] } {
        unset input_arr(y)
    }

    set validated_p 0
    # validate input
    # else should default to 404 at switch in View section.

    # validate input values for specific modes
    # failovers for permissions follow reverse order (skipping ok): admin_p delete_p write_p create_p read_p
    # possibilities are: d, t, w, e, v, l, r, "" where "" is invalid input or unreconcilable error condition.
    # options include    d, l, r, t, e, "", w, v
    set http_header_method [ad_conn method]
    ns_log Notice "tickets.tcl(141): initial mode $mode, next_mode $next_mode, http_header_method ${http_header_method}"



    # ACTIONS, PROCESSES / MODEL
    ns_log Notice "tickets.tcl(268): mode $mode next_mode $next_mode validated $validated_p"
    if { $validated_p } {
        ns_log Notice "tickets.tcl ACTION mode $mode validated_p 1"
        # execute process using validated input
        # IF is used instead of SWITCH, so multiple sub-modes can be processed in a single mode.

    }

} else {
    # form not posted
 
}


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

set context [list $title]
