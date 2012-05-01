module Voicemail
  class MailboxMessagesController < ApplicationController
    attr_accessor :current_message
    def run
      message_loop
    end

    def message_loop
      number = storage.count_new_messages(mailbox[:id])
      if number > 0
        next_message
      else
        bail_out
      end
    end

    def next_message
      #this sets the current message and calls handle
      current_message = storage.next_new_message(mailbox[:id])
      handle_message
    end

    def handle_message
      intro_message
      play_message
    end

    def play_message
      # here goes the main menu
      # can also recurse to rewind 
      menu current_message[:uri], config[:voicemail].messages.menu,
         :timeout => config[:voicemail].menu_timeout, :tries => config[:voicemail].menu_tries do
        match 1 do 
          archive_message
          message_loop
        end
        match 3 do 
          delete_message
          message_loop
        end
        match 4 do 
          rewind_message
        end
        match 9 do
          archive_message
          main_menu
        end
   
        timeout do
          play config[:voicemail].mailbox.menu_timeout_message
        end 
        invalid do
          play config[:voicemail].mailbox.menu_invalid_message
        end
   
        failure do
          play config[:voicemail].mailbox.menu_failure_message
          hangup
        end
      end
    end

    def intro_message
      play config[:voicemail].messages.message_received_on
      play current_message[:received]
      play config[:voicemail].messages.from
      play current_message[:from]
    end

    def rewind_message
      play_message
    end

    def archive_message
      #archives current message
    end

    def delete_message
      #deletes current message
    end

    def bail_out
      play config[:voicemail].messages.no_new_messages
      main_menu
    end

    def section_menu
      menu config[:voicemail].mailbox.menu_greeting,
         :timeout => config[:voicemail].menu_timeout, :tries => config[:voicemail].menu_tries do
        match 1 do 
          listen_to_messages
        end
        match 2 do 
          set_greeting
        end
        match 3 do 
          set_pin
        end
   
        timeout do
          play config[:voicemail].mailbox.menu_timeout_message
        end 
        invalid do
          play config[:voicemail].mailbox.menu_invalid_message
        end
   
        failure do
          play config[:voicemail].mailbox.menu_failure_message
          hangup
        end
      end

    end
  end
end