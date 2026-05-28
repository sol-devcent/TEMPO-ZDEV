
PROCESS BEFORE OUTPUT.

  MODULE m_status_9010.

  LOOP AT t_9010 WITH CONTROL tc_9010
                      CURSOR tc_9010-current_line.

    FIELD t_9010-select MODULE m_disable_cor.

    MODULE m_display_billing.

  ENDLOOP.

PROCESS AFTER INPUT.

  MODULE m_exit AT EXIT-COMMAND.

  LOOP AT t_9010.

    MODULE m_edit_record.

    FIELD t_9010-kunnr MODULE m_display_detail_cust AT CURSOR-SELECTION.
    FIELD t_9010-ebeln MODULE m_display_detail_po AT CURSOR-SELECTION.
  ENDLOOP.

  MODULE m_user_command_9010.

PROCESS ON VALUE-REQUEST.
  FIELD bseg-kidno MODULE value_request.


