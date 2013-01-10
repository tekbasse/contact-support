-- customer-service-create.sql
--
-- @license GNU GENERAL PUBLIC LICENSE, Version 3

 -- instead of support_request.sequence_value which tracks sequential number
 -- of tickets opened per day,
 -- List number of tickets opened within a period TBD by parameter
 -- or by number of open tickets ahead (by parameter)
 -- or by average response time to opened tickets within (parameter period) and
 --business hours (parameter). 
create table cs_tickets (
    ticket_id           integer not null primary key,
    package_id          integer not null,
    customer_id         varchar(100),
 -- authenticated_by is handy for indirect posts (such as via call center operator)
    authenticated_by    varchar(40),
    ticket_category_id  varchar(100),
    subject             varchar(100),
    opened_by           integer,
    time_opened         timestamptz,
    time_closed         timestamptz not null,
    privacy_level       varchar(1),
    -- a number, 0 no privacy requirements
    --           5 requires ssl to see, no content via notifications
    --           9 don't show to anyone but submitter via ssl
    trashed_p            varchar(1),
    priority             integer,
   -- for delegating/screening/escalating
   -- app note. When these change, log to internal_notes in a new cs_ticket_message
    assigned_to          integer,
    assigned_by          integer
);


create table cs_ticket_messages (
  -- aka support_content.id
    post_id          integer not null primary key,
    package_id       integer not null,
  -- aka support_content.support_request_id
    ticket_id        integer not null,
    posted_by        integer not null,
    post_time        timestamptz no null,
  -- aka support_content.details
    message          text,
    internal_notes   text
    -- internal notes includes the values of variable_names_avail, if any;
    -- and actions, such as ticket status changes, cgi vars passed in a form, as well
    -- as internal notes for ticket solvers etc.
);
        

 --aka canned_response table
create table cs_message_templates (
    template_id      integer not null primary key,
    package_id       integer not null,
    active_p         varchar(1),
    title            varchar(100),
    subject          varchar(200),
    variables        text,
    -- this lists the variable names that customer service can
    -- use in this particular email -- for info only
    message_content  text,
    last_modified    timestamptz not null,
    last_modified_by integer,
);

CREATE TABLE cs_categories (
    id integer not null,
    label varchar(80),
    grouping varchar(20),
    active_p varchar(1) default '1',
    description text
);

