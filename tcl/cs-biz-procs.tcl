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
    # cs_ticket_create (init new ticket, open, cs_ticket_message_create)


}

ad_proc -private cs_ticket_message_create {
    args
} {
    Create a message for a ticket_id
} {
    upvar 1 instance_id instance_id

}


# cs_announce (cs rep to multple customers) 
    # Send announcement / notifiy to subset of customers by customer_ref, ticket_id is the one
    # that is related to announcement. When ticket_id closes, announcement closes.

# cs_ticket_open (maybe it was closed)
# cs_ticket_close_by_customer
# cs_ticket_close_by_rep

# cs_ticket_subscribe
# cs_ticket_unsubscribe
# cs_ticket_subscriptions_change



# cs_ticket_message_create

# cs_cats_of_role_read
# cs_roles_of_cat_read

# if !$tickets.unscheduled_service_req_p
#  ask customer when is preferred service time
#  in case of service interruptions are needed.
#  and ask when is most important that interruptions are minimized.

# if $tickets.scheduled_maint_req_p,
# When $scheduled_operation_p ie scheduled, set notifications of
# alert customers according to parameter SchedRemindersList
#


ad_proc -private cs_notify_customer_reps {
    ticket_id
    {subject ""}
    {message ""}
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
