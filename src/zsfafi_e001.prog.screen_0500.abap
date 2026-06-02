
PROCESS BEFORE OUTPUT.
  MODULE status_0500.
  LOOP WITH CONTROL input.
    MODULE fill_table_control.
  ENDLOOP.
*
PROCESS AFTER INPUT.
  MODULE cancel AT EXIT-COMMAND.
  LOOP WITH CONTROL input.
    CHAIN.
      FIELD: gt_vout-chbox.
      MODULE read_table_control_chbox ON CHAIN-REQUEST.

      FIELD: gt_vout-kunnr,
             gt_vout-zuonr,
             gt_vout-ztext.
      MODULE read_table_control ON CHAIN-REQUEST.
    ENDCHAIN.
  ENDLOOP.
  MODULE user_command_0100.
