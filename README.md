This project is created and customized for personal usage only. It is a client for custom server.

The main goal was to use API for smart home and display data in a suitable way.

Custom server is created using Java, Spring. https://github.com/PhilipJFry2995/home-info-server

# Main features:

- Interact with the smart home - curtains, LED light, warm floor, etc
- Interact with air conditioner API to turn on/off, set temperature, mode, etc.
- Interact with Shelly Door/Window 2 device API to detect windows opening/closing, light level, etc.
- Use custom scenarios, combining features above.
- Use custom nodes, which provide temperature and humidity values.
- Use qbittorent API to download files, provide storage info, send notifications in Telegram
- Display heat map of home
- Use sockets to notify connected application about changes
- Display working time (electricity availability)
- Use NFC tokens to activate scenarios