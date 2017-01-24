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

# cs_ticket_create (init new ticket, open, cs_ticket_message_create)
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

