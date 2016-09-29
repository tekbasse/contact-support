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
    set customer_id_list [list $user_id]
    return $customer_id_list
}

