import sys
import random

import bot
import irc_message
import extension

import extensions.osc_sender as osc_sender
import extensions.sundry_commands as sundry_commands


# handle command-line args
if len(sys.argv) < 3:
   print('Usage:', sys.argv[0], 'server nick [channel_list]')
   sys.exit(1)

server = sys.argv[1]
start_nick = sys.argv[2]
channels = []
if len(sys.argv) == 4:
   channels = sys.argv[3].split(',')

# any settings for the bot
settings = {
   'show_say': True,
   'message_print_level': bot.Bot.UNHANDLED_MESSAGES,
}

# initialize bot
jbot = bot.Bot(settings)

# initialize all extensions
osc_ext = osc_sender.OscSender(jbot)
sc_ext_settings = {
   'show_starts': False,
   'show_ends': False,
   'show_server_stats': False,
   'show_server_info': False,
   'show_motd': False,
   'show_names_list': False,
}
sc_ext = sundry_commands.SundryCommands(jbot, sc_ext_settings)

# Order of extensions is important!
jbot.set_extensions([
   osc_ext,
   sc_ext,
])

# connect to the given server with the given nick
jbot.connect(server, start_nick)

# join the specified channels
for chan in channels:
   jbot.join(chan)

# start interacting with the server
jbot.interact()

# once the bot is killed by the user or server,
# call its cleanup procedures and its extensions'
jbot.cleanup()
