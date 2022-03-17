# Rod's Music Selector

Music selection and play.

I started this project because all of the players I have to access music
from my Twoky server didn't provide a search capability. If I want to play a
particular album I have to scroll through lists arranged by artist or
album or genre which is a pain. I also wanted to play on my Yamaha MusicCast
speakers.

Both Twonky Server and MusicCast have APIs so I got stuck in.

Twonky: https://docs.twonky.com/display/TS/Twonky+Server+REST+API+Specification
Yamaha Extended Control API (Basic): https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&cad=rja&uact=8&ved=2ahUKEwi_o5aV4sz2AhXMilwKHQe6CJcQFnoECAkQAQ&url=https%3A%2F%2Fcommunity-openhab-org.s3-eu-central-1.amazonaws.com%2Foriginal%2F2X%2F9%2F931ea88e30cf0f05fcdee79816eb4d3f12dd4d70.pdf&usg=AOvVaw0fhNd8XOaDjSYBPZniicem
Yamaha Extended Control API (Advanced): https://forum.smartapfel.de/attachment/4371-yxc-api-spec-advanced-pdf/

I wanted the facility available on Android devices and linux so chose Flutter
as the implementation platform which gave me the opportunity to learn Flutter
and Dart.1

## Running
The only configuration necessary is to set the IP address of the Twonky server.
Click on the menu (top right) and select settings. There you can set the IP
and Port for Twonky Server.

## Futures
1) I hope to extend this app to other music servers and use SSDP for discovery
to avoid the need for setting the IP of the server.
2) Currently only 1 MusicCast speaker can be selected, I hope to be able to
link several using the MusicCast protocols.
