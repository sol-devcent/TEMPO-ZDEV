
PROCESS BEFORE OUTPUT.
  MODULE status.

  MODULE pbo.

PROCESS AFTER INPUT.

  MODULE exit AT EXIT-COMMAND.

  MODULE pai.

  MODULE user_command.

PROCESS ON VALUE-REQUEST.

  FIELD zfexpense-zidno_low MODULE value_zidno_low.
  FIELD zfexpense-zidno_high MODULE value_zidno_high.
*  FIELD zfexpense-hkont MODULE value_hkont.
  FIELD zfexpense-ktext MODULE value_hkont.
