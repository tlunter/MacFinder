# MAC Finder

A simple web server written using Haskell, Scotty and Redis to power an [IFTTT](https://ifttt.com) trigger.
A MAC address can be POSTed to http://.../lease in the body of the request, looked up in Redis, and a name is sent to IFTTT to trigger some action.
The idea is to trigger a notification on my phone and computer whenever someone new connects to my router.
My router will cURL the web server using dnsmasq-dhcp's script support.
