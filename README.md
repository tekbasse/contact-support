Customer Service
================

For the latest updates to this readme file, see: http://openacs.org/xowiki/customer-service

The lastest version of the code is available at the development site:
 http://github.com/tekbasse/customer-service

introduction
------------

Customer Service package manages interactions and issues with customers.


introduction
------------

Customer Service is an OpenACS package using substitution templates for
managing outbound, canned messages.

It is inspired from OpenACS' ecommerce package. Administrators
 have voiced interest in having some kind of auxiliary customer service
 ticket system that can be used in conjunction with other services.

license
-------
Copyright (c) 2016 Benjamin Brink
po box 20, Marylhurst, OR 97036-0020 usa
email: tekbasse@yahoo.com

Customer-Service is open source and published under the GNU General Public License, 
consistent with the OpenACS system: http://www.gnu.org/licenses/gpl.html

A local copy is available at customer-service/www/doc/LICENSE.html

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

features
--------

Tickets can be assigned to multiple admin users.

Assignments can be modified by any admin.

Tickets can be subscribed by multiple representatives of a customer.

Subscribers can remove themselves from subscription.

Subscriber admins can subscribe others in their organization.

Subscribers can respond via email.

Subscriber shows ticket status as open or closed independent of Admin after opening.
Admin shows ticket status as open,closed, or:
1.   waiting for a specific admin to respond (ticket shows as high priority / highlighted for them).
2.   waiting for other nonspecific admin action
3.   raise priority during a scheduled time period (deactivate at end of period, or manually by anyone)

By having independent status for Admin and clients, 
each can close ticket depending on if something is actionable on their "side".
No false flags to haunt actions-to-take lists.

No UI javascript is used, so technologies with limited UI can use it.

Capable of handling secure threads.

Tickets can be prioritized (triaged).

Uses Q-Forms, and subsequently benefits from its features.

Modifiable for custom deployments.






