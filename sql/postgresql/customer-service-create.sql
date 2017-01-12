-- customer-service-create.sql
--
-- @license GNU GENERAL PUBLIC LICENSE, Version 3

 -- instead of support_request.sequence_value which tracks sequential number
 -- of tickets opened per day,
 -- List number of tickets opened within a period TBD by parameter
 -- or by number of open tickets ahead (by parameter)
 -- or by average response time to opened tickets within (parameter period) and
 --business hours (parameter). 

CREATE SEQUENCE cs_id_seq start 10000;
SELECT nextval ('cs_id_seq');

CREATE TABLE cs_ticket_ref_id_map (
    ref varchar(200) not null,
    id  integer not null
); 

create index cs_ticket_ref_id_map_ref_idx on cs_ticket_ref_id_map (ref);
create index cs_ticket_ref_id_map_id_idx on cs_ticket_ref_id_map (id);

CREATE TABLE cs_customer_ref_id_map (
    customer_ref varchar(100),
    customer_id integer not null
);

CREATE TABLE cs_tickets (
    ticket_id           integer not null,
    instance_id         integer not null,
    customer_id         integer not null,
 -- authenticated_by is handy for indirect posts (such as via call center operator)
    authenticated_by    varchar(40),
    ticket_category_id  varchar(100),
    current_tier_level  integer,
    subject             varchar(100),
    opened_by           integer not null,
    cs_time_opened      timestamptz not null,
    cs_time_closed      timestamptz,
    user_time_opened    timestamptz not null,
    user_time_closed    timestamptz,
    -- a number, 0 no privacy requirements
    --           5 requires ssl to see, no content via notifications
    --           9 don't show to anyone but submitter via ssl
    privacy_level       varchar(1),
    trashed_p           varchar(1),
    priority            integer
);

CREATE TABLE cs_ticket_stats (
    ticket_id           integer not null,
    cs_first_response_s integer,
    -- This is time to final ticket closing to help anticipate recovery time
    cs_final_response_s integer,
    -- useful to help segment response depending on triaged/assigned tier_level
    -- tier_level might be automatically initally triaged based on ticket_category_id
    cs_final_tier_level integer
);

CREATE TABLE cs_ticket_action_log (
    ticket_id        integer not null,
    instance_id      integer not null,
    -- for delegating/screening/escalating
    -- app note. When these change, log to internal_notes in a new cs_ticket_message
    rep_ids            text,
    -- a = assigned
    -- d = dropped
    -- c = closed
    op_type            varchar(2),
    -- operation initiated by (user_id of rep), or
    -- instance_id = assigned by software (package_id ie object_id)
    op_by         integer,
    op_time       timestampz default now()
);

create index cs_tickets_ticket_id_idx on cs_tickets (ticket_id);
create index cs_tickets_instance_id_idx on cs_tickets (instance_id);
create index cs_tickets_customer_id_idx on cs_tickets (customer_id);


CREATE TABLE cs_ticket_messages (
  -- aka support_content.id
    post_id          integer not null,
    instance_id      integer not null,
  -- aka support_content.support_request_id
    ticket_id        integer not null,
    posted_by        integer not null,
    post_time        timestamptz not null,
  -- aka support_content.details
    message          text,
    -- a number, 0 no privacy requirements
    --           5 requires ssl to see, no content via notifications
    --           9 don't show to anyone but submitter via ssl
    privacy_level    varchar(1),
    -- internal notes includes the values of variable_names_avail, if any;
    -- and actions, such as ticket status changes, cgi vars passed in a form, as well
    -- as internal notes for ticket solvers etc.
    internal_notes   text,
    -- space delimited list of cs representative user_ids.
    assigned_to      text,
    -- space delimited list of customer user_ids. Unsubscribing adds a message to that effect.
    subscribed       text,
    trashed_p        varchar(1)
);

create index cs_ticket_messages_ticket_id_idx on cs_ticket_messages(ticket_id);
create index cs_ticket_messages_instance_id_idx on  cs_ticket_messages(instance_id);

CREATE TABLE cs_customer_stats (
    customer_id  integer,
    ticket_id integer,
    -- The cs message_id might not be the prior id in a sequence.
    -- Customer might post multiple messages between responses
    -- from cs.
    cs_message_id integer,
    message_id integer,
    duration_to_reply_s integer,
    -- Day of week of customer reply. Hint:
    -- clock format \clock seconds\ -format %w (or %u)
    -- 0 = Sunday, 1 = monday, 6 = saturday, 7 = sunday
    -- use int(fmod(%w or %u, 7)) to standardize Sundays to 0.
    weekday_n        integer,
    -- time of day in decimal hours from 0:00am ie H+ M*100/60.
    -- Hint:
    -- set hm_list \clock format \clock seconds\ -format "%H %M"\ 
    -- set hour_integer \expr \lindex hm 0\ + \lindex hm 1\ * 5 / 3
    time_m integer,

);

 --aka canned_response table
CREATE TABLE cs_message_templates (
    template_id      integer not null primary key,
    instance_id      integer not null,
    -- automatically inactivate old, and issue new tempalate_id
    active_p         varchar(1),
    label            varchar(30),
    title            varchar(100),
    subject          varchar(200),
    -- this lists the variable names that customer service can
    -- use in this particular email -- for info only
    variables        text,
    message_content  text,
    created    timestamptz not null,
    created_by integer
);

create index cs_message_templates_template_id_idx on cs_message_templates(template_id);
create index cs_message_templates_instance_id_idx on cs_message_templates(instance_id);
create index cs_message_templates_label_idx on cs_message_templates(label);

CREATE TABLE cs_categories (
    id               integer not null,
    -- if this a sub category of another category, parent category_id
    parent_id        integer,
    instance_id      integer,
    -- to sort categories
    order_value      integer,
    label            varchar(80),
    grouping         varchar(20),
    active_p         varchar(1) default '1',
    description      text
);

create index cs_categories_id_idx on cs_categories(id);
create index cs_categories_label_idx on cs_categories(label);
create index cs_categories_grouping_idx on cs_categories(grouping);

-- ticket_id subscribers (users) map
CREATE TABLE cs_ticket_users_map (
       ticket_id     integer,
       -- one record for each user that currently subscribes to ticket
       user_id       integer
);

create index cs_ticket_users_map_ticket_id_idx on cs_ticket_users_map(ticket_id);
create index cs_ticket_users_map_user_id_idx on cs_ticket_users_map(user_id);


-- ticket_id cs_rep (admins) map
CREATE TABLE cs_ticket_rep_map (
       ticket_id     integer,
       -- one record for each cs rep / admin that is currently assigned to ticket
       user_id       integer
);

create index cs_ticket_rep_map_ticket_id_idx on cs_ticket_rep_map(ticket_id);
create index cs_ticket_rep_map_user_id_idx on cs_ticket_rep_map(user_id);

-- Answers question, who is automatically assigned by ticket of posted category
CREATE TABLE cs_cat_assignment_map (
       category_id   integer,
       -- one record for each assigned user to a category
       user_id       integer
);

create index cs_cat_assignment_map_category_id_idx on cs_cat_assignment_map(category_id);
create index cs_cat_assignment_map_user_id_idx on cs_cat_assignment_map(user_id);

