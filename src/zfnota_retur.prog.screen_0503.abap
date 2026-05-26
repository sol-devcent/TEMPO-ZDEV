
PROCESS BEFORE OUTPUT.
  MODULE status_0503.

  MODULE modify_503.

PROCESS AFTER INPUT.
  CHAIN.
    FIELD va_nonr.
    FIELD va_zuonr.
    FIELD va_kunnr.
    FIELD va_name1.
    FIELD va_alamat.
    FIELD va_kota.
    FIELD va_npwp.
    FIELD va_nppkp.
    FIELD va_refnr.
    field va_zdesc.
  ENDCHAIN.

  MODULE user_command_0503.
