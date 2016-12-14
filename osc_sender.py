"""
   Echo extension.
   Simple extension that does nothing more than echo whatever
   someone says back at them.
   Hooks: PRIVMSG
"""

import irc_message
import extension
import sys
sys.path.append('/home/stark/.local/lib/python3.5/site-packages/')

from pythonosc import udp_client


class OscSender(extension.Extension):
   name = "OscSender"

   def __init__(self, bot):
      self.client = udp_client.SimpleUDPClient('127.0.0.1', 6666)
      super(OscSender, self).__init__(bot)
      self.hooks = {
         'PRIVMSG': self.privmsg_handler
      }


   # Handle PRIVMSG commands.
   def privmsg_handler(self, msg):
      sender = msg.getSender()
      recipient = msg.params[0]
      if recipient == self.bot.nick:
         # private message
         pass
      else:
         self.client.send_message('/irc/message', sender + ' ' + msg.trail)
         # self.client.send_message('/irc/message', [1,2,3,4])

      return True


   def cleanup(self):
      pass
