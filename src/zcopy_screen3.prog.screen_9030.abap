
PROCESS BEFORE OUTPUT.
  LOOP AT   t_fidt0003
       WITH CONTROL tc_9030
       CURSOR tc_9030-current_line.

    MODULE tc_9030_get_lines.
  ENDLOOP.

  MODULE status_9030.
*
PROCESS AFTER INPUT.
  LOOP AT t_fidt0003.
    FIELD  t_fidt0003-sel
      MODULE tc_9030_mark ON REQUEST.
  ENDLOOP.

  MODULE tc_9030_user_command.

  MODULE user_command_9030.
