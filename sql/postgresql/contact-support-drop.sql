-- customer-support-drop.sql
--
-- @license GNU GENERAL PUBLIC LICENSE, Version 2

drop index cs_ticket_op_periods_op_done_p_idx;
drop index cs_ticket_op_periods_ticket_id_idx;
drop index cs_ticket_op_periods_instance_id_idx;

DROP TABLE cs_ticket_op_periods;

drop index cs_sched_messages_triggered_p_idx;
drop index cs_sched_messages_trigger_ts_idx;
drop index cs_sched_messages_ticket_id_idx;
drop index cs_sched_messages_instance_id_idx;

DROP TABLE cs_sched_messages;

drop index cs_contact_rep_cat_map_user_id_idx;
drop index cs_contact_rep_cat_map_category_id_idx;
drop index cs_contact_rep_cat_map_instance_id_idx;

DROP TABLE cs_contact_rep_cat_map;



drop index cs_support_rep_cat_map_user_id_idx;
drop index cs_support_rep_cat_map_category_id_idx;
drop index cs_support_rep_cat_map_instance_id_idx;

DROP TABLE cs_support_rep_cat_map;


drop index cs_support_rep_ticket_map_instance_id_idx;
drop index cs_support_rep_ticket_map_user_id_idx;
drop index cs_support_rep_ticket_map_ticket_id_idx;

DROP TABLE cs_support_rep_ticket_map;

drop index cs_contact_rep_ticket_map_user_id_idx;
drop index cs_contact_rep_ticket_map_ticket_id_idx;
drop index cs_contact_rep_ticket_map_instance_id_idx;

DROP TABLE cs_contact_rep_ticket_map;

drop index cs_categories_parent_id_idx;
drop index cs_categories_label_idx;
drop index cs_categories_id_idx;
drop index cs_categories_instance_id_idx;

DROP TABLE cs_categories;

drop index cs_message_templates_label_idx;
drop index cs_message_templates_instance_id_idx;
drop index cs_message_templates_template_id_idx;

DROP TABLE cs_message_templates;

drop index cs_contact_stats_contact_id_idx;
drop index cs_contact_stats_instance_id_idx;
drop index cs_contact_stats_ticket_id_idx;

DROP TABLE cs_contact_stats;

drop index cs_ticket_messages_post_id_idx;
drop index cs_ticket_messages_trashed_p_idx;
drop index cs_ticket_messages_instance_id_idx;
drop index cs_ticket_messages_ticket_id_idx;

DROP TABLE cs_ticket_messages;


drop index cs_ticket_action_log_instance_id_idx;
drop index cs_ticket_action_log_ticket_id_idx;

DROP TABLE cs_ticket_action_log;


drop index cs_ticket_stats_instance_id_idx;
drop index cs_ticket_stats_ticket_id_idx;

DROP TABLE cs_ticket_stats;


drop index cs_tickets_trashed_p_idx;
drop index cs_tickets_user_open_p_idx;
drop index cs_tickets_cs_open_p_idx;
drop index cs_tickets_instance_id_idx;
drop index cs_tickets_ticket_id_idx;
drop index cs_tickets_contact_id_idx;

DROP TABLE cs_tickets;

drop index cs_announcements_instance_id_idx;
drop index cs_announcements_expired_p_idx;
drop index cs_announcements_expire_ts_idx;
drop index cs_announcements_ticket_id_idx;
drop index cs_announcements_id_idx;

DROP TABLE cs_announcements;

drop index cs_ticket_ref_id_map_instance_idx;
drop index cs_ticket_ref_id_map_id_idx;
drop index cs_ticket_ref_id_map_ref_idx;

DROP TABLE cs_ticket_ref_id_map;

DROP SEQUENCE cs_id_seq;


