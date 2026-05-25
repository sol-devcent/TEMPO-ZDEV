
PROCESS BEFORE OUTPUT.
  MODULE status.

  MODULE pbo.

  LOOP WITH CONTROL tc_nopol.
    MODULE fill_table_control.
  ENDLOOP.

PROCESS AFTER INPUT.

  MODULE exit AT EXIT-COMMAND.

  LOOP WITH CONTROL tc_nopol.
    CHAIN.
      FIELD zfmstken-buzei.
      FIELD zfmstken-znopol.
      FIELD zfmstken-keterangan.
      MODULE read_table_control.
    ENDCHAIN.
  ENDLOOP.

  MODULE pai.

  MODULE user_command.

PROCESS ON VALUE-REQUEST.

  FIELD zfmstken-anln1 MODULE value-anln1.
  FIELD zfmstken-anln2 MODULE value-anln2.
