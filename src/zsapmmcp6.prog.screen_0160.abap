PROCESS BEFORE OUTPUT.

  MODULE STATUS_SETZEN.

PROCESS AFTER INPUT.

* Replace Module EXIT_COMMAND with MODULE EXIT_COM
* to bypass Tcode Checking when exit
  MODULE EXIT_COM AT EXIT-COMMAND.
*  MODULE EXIT_COMMAND AT EXIT-COMMAND.
  CHAIN.
    FIELD RMCP2-MCINF.
    FIELD RMCP2-VRSIA.
* Remark to bypass consistent planning check
* Original Tcode MC9C can only use for infostructure
* that use consisntent planning
*    MODULE EINGABE_PRUEFEN_0160.
    MODULE FCODE_PRUEFEN.
  ENDCHAIN.
