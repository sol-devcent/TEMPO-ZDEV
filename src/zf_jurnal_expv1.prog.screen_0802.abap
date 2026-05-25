
PROCESS BEFORE OUTPUT.
  MODULE status.

  MODULE pbo.

PROCESS AFTER INPUT.

  MODULE exit AT EXIT-COMMAND.

  MODULE pai.

  MODULE user_command.

PROCESS ON VALUE-REQUEST.

  FIELD zfmstper-zidke MODULE value_zidke.
  FIELD zfmstper-pernr MODULE value_pernr.
  FIELD zfmstper-lifnr MODULE value_lifnr.
  FIELD zfmstper-kunnr MODULE value_kunnr.
  FIELD zfmstper-kostl MODULE value_kostl.
  FIELD zfmstper-wwpfn MODULE value_wwpfn.
  FIELD zfmstper-wwsfr MODULE value-wwsfr.
  FIELD zfmstper-wwpos MODULE value-wwpos.
