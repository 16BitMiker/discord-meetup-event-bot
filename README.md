# Discord Event Meetup Bot v0.1

Discord webhook bot that posts a [meetup.com](https://www.meetup.com/) event update once per day.

#### Features:

- Randomized message border.
- Will randomly cycle through upcoming meetup events .
- Won't post events that are taking place within 24 hours of the event.

## Basic Use

- **discord** = put your channel [webhook](https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks) here.
- **url** = url to meetup groups events

```
# discord webhook
discord = 'Discord Webhook'

# meetup event url
meetup = 'https://www.meetup.com/GROUPNAME/events/'

# initialize bot
discord = Discord_Meetup_Updater.new(meetup,discord)

# runs the bot
discord.run()
```

## Example Output

📣 📣 📣 📣 📣 📣 📣 📣 📣 📣 
*PSSSSSSSSSSSSSSSSSSSSSSST*
Check Out This Upcoming Event:
**Title**: Let's Go to the ROM
**Date**: Tue, Nov 15, 2022
**Time**: 6:00 PM
RSVP @ https://meetup.com//geekalicious/events/289603587/ 👀
📣 📣 📣 📣 📣 📣 📣 📣 📣 📣
