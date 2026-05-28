
PROCESS BEFORE OUTPUT.
  MODULE status.

  MODULE pbo.

  LOOP WITH CONTROL tc_notes.
    MODULE fill_tc_notes.
  ENDLOOP.

PROCESS AFTER INPUT.
  MODULE exit AT EXIT-COMMAND.

  MODULE pai.

  LOOP WITH CONTROL tc_notes.
    CHAIN.
      FIELD gs_notes-gstrp.
      FIELD gs_notes-sgtxt.

      MODULE read_tc_notes.
    ENDCHAIN.
  ENDLOOP.

  MODULE user_command.
