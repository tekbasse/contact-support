#customer-service/tcl/cs-biz-procs.tcl
ad_library {

    business procs for customer-service
    @creation-date 21 Jan 2017
    @Copyright (c) 2017 Benjamin Brink
    @license GNU General Public License 2
    @project home: http://github.com/tekbasse/customer-service
    @address: po box 20, Marylhurst, OR 97036-0020 usa
    @email: tekbasse@yahoo.com
    
}

ad_proc -public cs_ticket_create {
    args
} {
    Create a ticket.
} {
    upvar 1 instance_id instance_id
    # init new ticket, open, 


# if !$tickets.unscheduled_service_req_p
#  ask customer when is preferred service time (in the first created message).
#  in case of service interruptions are needed.
#  and ask when is most important that interruptions are minimized.

# if $tickets.scheduled_maint_req_p,
# When $scheduled_operation_p ie scheduled, set notifications of
# alert customers according to parameter SchedRemindersList
#



    # cs_ticket_message_create

##code
}

ad_proc -private cs_ticket_message_create {
    args
} {
    Create a message for a ticket_id
} {
    upvar 1 instance_id instance_id
    ##code
}

ad_proc -public cs_announce {
    announcement_text
    ann_type
    {customer_id_list ""}
    {expiration ""}
    {ticket_id ""}
    {allow_html_p "0"}
} {
    Show announcment to customers who visit customer-service package. 
    Expires when ticket_id expires or expiration, and/or manual expiration.
    If allow_html_p is one, allows html to be in announcement_text
    <br/>
    If customer_id_list is not empty, announcement only applies to customers referenced in customer_id_list.
    <br/>
    Expiration can be relative tcl "now + 3 days, now + 3 hours, now + 15 minutes or yyyy-mm-dd hh:mm:ss"

    @return 1 if no errors, otherwise returns 0.
} {
    set success_p 1

    if { [catch {set expires_ts [clock scan $expiration] } result] } {
        ns_log Notice "cs_announce: instance_id '${instance_id}' user_id '${user_id} expiration '${expiration}' Error '${result}'"
        set success_p 0
    } 

    # cs_announce (cs rep to multple customers) 
    # Send announcement / notifiy to subset of customers by customer_ref, ticket_id is the one
    # that is related to announcement. When ticket_id closes, announcement closes.

    ##code
    
    return $success_p
}

ad_proc -public cs_ticket_open {
    args
} {
    Open a customer-service ticket.

    @return ticket_id, or empty string if fails.
} {
    upvar 1 instance_id instance_id
    # Remember that it might have been closed (already exists and re-opened)
    ##code

    return $ticket_id
}


ad_proc -public cs_ticket_close_by_customer {
    args
} {
    Close ticket by customer rep.
} {
    upvar 1 instance_id instance_id
    set success_p 1

    ##code
    return $success_p
}

ad_proc -public cs_ticket_close_by_rep {
    args
} {
    Close ticket by customer support.
} {
    upvar 1 instance_id instance_id
    set success_p 1
    ##code

    return $success_p
}

ad_proc -private cs_ticket_subscribe {
    ticket_id
    user_id_list
} {
    Subscribe user_ids to ticket.
} {
    upvar 1 instance_id instance_id
    # subscribe user to ticket_id
    set success_p 1

    ##code
    return $success_p
}

ad_proc -private cs_ticket_unsubscribe {
    ticket_id
    user_id_list
} {
    Unsubscribe user_ids to ticket.
} {
    upvar 1 instance_id instance_id
    # unsubscribe user to ticket_id
    set success_p 1

    ##code
    return $success_p
}


ad_proc -private cs_ticket_subscriptions_change {
    args
} {
    Change subscriptions for a ticket.
} {
    upvar 1 instance_id instance_id
    # cs_ticket_subscriptions_change
    set success_p 1

    ##code 
    return $success_p
}

ad_proc -private cs_ticket_message_create {
    args
} {
    Post a message to a ticket.
} {
    upvar 1 instance_id instance_id
    # cs_ticket_subscriptions_change
    set success_p 1

    ##code 
    return $success_p
}


ad_proc -private cs_categories {
} {
    Read categories as a list of lists.
} {
    upvar 1 instance_id instance_id
    ##code
    return $categories_lists
}



ad_proc -private cs_notify_customer_reps {
    ticket_id
    {subject ""}
    {message ""}
    {immediate_p "1"}
    {message_id ""}
} {
    Notify customer reps that subscribe to ticket.
} {
    ##code

    # based on hf_monitor_alert_trigger (code extracted below)
    # sender email is systemowner
    # to get user_id of systemowner:
    # party::get_by_email -email $email
    set sysowner_email [ad_system_owner]
    set sysowner_user_id [party::get_by_email -email $sysowner_email]

    # What users to send alert to?
    set users_list [cs_customer_reps_of_ticket $ticket_id]
    if { [llength $users_list] > 0 } {
        # get TO emails from user_id
        set email_addrs_list [list ]
        foreach uid $users_list {
            lappend email_addrs_list [party::email -party_id $uid]
        }
        
        # What else is needed to send alert message?
        set ticket_ref [cs_t_ref_from_id $ticket_id]
        set subject "#customer-service.ticket# #customer-service.Asset_Monitor# id ${monitor_id} for ${label}: ${alert_title}"
        set body $alert_message
        # post to logged in user pages 
        hf_log_create $asset_id "#customer-service.Asset_Monitor#" "alert" "id ${monitor_id} ${subject} \n Message: ${body}" $user_id $instance_id 

        # send email message
        append body "#customer-service.Alerts_can_be_customized#. #customer-service.See_asset_configuration_for_details#."
        acs_mail_lite::send -send_immediately $immediate_p -to_addr $email_addrs_list -from_addr $sysowner_email -subject $subject -body $body

        # log/update alert status
        if { $immediate_p } {
            # show email has been sent
            
        } else {
            # show email has been scheduled for sending.
            ns_log Notice "cs_notify_customer_reps. ticket_id '${ticket_id}' message_id '${message_id}'"
        }
    }
    return 1
}


ad_proc -private cs_notify_support_reps {
    ticket
} {
    Notify support reps that subscribe to ticket.
} {
    ##code
    # based on cs_notify_customer_reps

}
