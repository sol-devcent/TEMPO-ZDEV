
PROCESS BEFORE OUTPUT.
  MODULE status_0100.
  LOOP WITH CONTROL input.
    MODULE fill_table_control.
  ENDLOOP.

PROCESS AFTER INPUT.
  MODULE cancel AT EXIT-COMMAND.
  LOOP WITH CONTROL input.
    MODULE read_table_control.
  ENDLOOP.
  MODULE user_command_0100.

PROCESS ON VALUE-REQUEST.
  FIELD gt_zfarpotd-zterm MODULE value_zterm.
  FIELD hkont MODULE value_hkont.
