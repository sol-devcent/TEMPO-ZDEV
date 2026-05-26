
PROCESS BEFORE OUTPUT.

  MODULE status_0600.

  MODULE modify.

PROCESS AFTER INPUT.
  CHAIN.
    FIELD bsis-monat.
    FIELD bsis-gjahr.
    FIELD bsas-monat.
    FIELD bsas-gjahr.
  ENDCHAIN.

  MODULE user_command_0600.
