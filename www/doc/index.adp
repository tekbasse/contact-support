<master>
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
<h1>Contact Support Documentation</h1>

<pre>(c) 2016 by Benjamin Brink
po box 20, Marylhurst, OR 97036-0020 usa
email: tekbasse@yahoo.com</pre>
<p>Open source <a href="LICENSE.html">License under GNU GPL</a></p>
<pre>
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see 
    <a href="http://www.gnu.org/licenses/">http://www.gnu.org/licenses/</a>.
</pre>

<h3>Contents</h3>
<ul>
<li>
Documentation from original <a href="ecommerce-cs">ecommerce contact-support feature</a> (for reference only)
</li>
</ul>

<h3>features (requested)</h3>

<ul><li>
tickets automatically alert to those assigned by tag/category or q-control package's company role.
</li><li>
replies to email notifications are posted to ticket.
</li><li>
    Ticket state can be set identical (open/closed), or
    is somewhat independent between support team and contacts
    to allow for tickets that require contacts to complete
    tasks without additional coordination with cs reps.
<pre>
  independent ticket state terminology:
  SST = support ticket state (open/closed)
  CST = contact ticket state (open/closed)
  When contact opens ticket, both CST and SST are opened for triage.
  When contact closes ticket, both CST and SST are closed.
  When support closes ticket, both CST and SST are closed
  When contact re-opens ticket or replies to ticket, ticket is triaged again by first tier.
  When support triages ticket, and more info needed by contact,
      ticket is SST is closed, CST remains open.
  When support triages new ticket, 
      qualified ticket remains open for both CST & SST.
      support categories and assigns ticket to a tier level and priority if different than default.
  When support triages a previously closed ticket,
      qualified ticket remains open for both CST & SST, and
      notifications sent to previously assigned reps.
      Otherwise SST is closed (with message sent to contact stating no support response needed).
  Contact asked to close CST ticket when they are finished with the topic internally.
</pre>
</li><li>
URL to ticket or ticket/message
</li><li>
ticket thread has reference by ticket#/message# or ticket_nbr-message_nbr.
</li><li>
ticket number is unqiue alphanumeric reference to hide system ticket and message number, based on open timestamp.
</li><li>
create a feedback package to integrate reviews of support..
</li><li>
Show stats (avg/min/max) response time over day/week/year of contact as well as support to antcipate response timing.
</li><li>
Show stats (avg/min/max) time to final ticket closing to help anticipate total down/recovery time.
</li><li>
Show graph of UTC time-in-day and time-in-week when responses are made of contact as well as support to anticipate response timing.
</li><li>
Send announcement / notification to subset of contacts by contact_ref. 
<pre>
Record notification in contact ticket history.
Announcement may have an expiration with it. 
If before expiration, present in contact_ref web pages with hide by user_id.
</pre>
</li><li>
Post an announcement on contact-support pages without notification when other users may be affected. 
<pre>
--to minimize tickets associated with a system wide issue. 
(click a button to be notified when issue is resolved).
This kind of announcement is not registered in a contact's ticket logs.
Active announcements of this type appear on admin pages, and 
is associated with a ticket, so that it can be automatically expired when ticket closes,
or manually expired by a cs rep.
</pre>
</li></ul>
