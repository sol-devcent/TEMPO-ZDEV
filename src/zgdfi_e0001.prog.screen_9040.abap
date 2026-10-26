
PROCESS BEFORE OUTPUT.

  MODULE m_status_9040.

PROCESS AFTER INPUT.

  MODULE m_exit AT EXIT-COMMAND.

  FIELD s911-ebeln MODULE m_check_ekko.

  CHAIN.
    FIELD d_hwaer1.
    FIELD s911-hwaer.

    MODULE m_fill_hwaer.
  ENDCHAIN.

  CHAIN.
    FIELD s911-ekgrp.
    FIELD s911-bsart.

    MODULE m_check_zgdfidt0001.
  ENDCHAIN.

  MODULE m_lock_record.

  MODULE m_user_command_9040.
