-- customer-service-create.sql
--
-- @license GNU GENERAL PUBLIC LICENSE, Version 3

 -- instead of support_request.sequence_value which tracks sequential number
 -- of tickets opened per day,
 -- List number of tickets opened within a period TBD by parameter
 -- or by number of open tickets ahead (by parameter)
 -- or by average response time to opened tickets within (parameter period) and
 --business hours (parameter). 

drop index cs_categories_grouping_idx;
drop index cs_categories_label_idx;
drop index cs_categories_id_idx;

DROP TABLE cs_categories;

drop index cs_message_templates_label_idx;
drop index cs_message_templates_instance_id_idx;
drop index cs_message_templates_template_id_idx;

DROP TABLE cs_message_templates;


drop index cs_ticket_messages_instance_id_idx;
drop index cs_ticket_messages_ticket_id_idx;

DROP TABLE cs_ticket_messages;


drop index cs_tickets_customer_id_idx;
drop index cs_tickets_instance_id_idx;
drop index cs_tickets_ticket_id_idx;

DROP TABLE cs_tickets;

drop sequence cs_id_seq;
