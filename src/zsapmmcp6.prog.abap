*********************************************************************
* Modulpool Planzahlenerfassung im Logistik-Informations-System
*********************************************************************
  INCLUDE MMCP6TOP.                    "Datenvereinbarungen

* INCLUDE MMCP6F02.  (WLYTST04)        "Dynamische Perform Routinen SOP

  INCLUDE MMCP6O00.                    "PBO-Module allgemein

  INCLUDE MMCP6I00.                    "PAI-Module allgemein

  INCLUDE MMCP6FA0.                    "FORM-Routinen Buchstabe A
  INCLUDE MMCP6FB0.                    "FORM-Routinen Buchstabe B
  INCLUDE MMCP6FBP.        "FORM-Routinen  für Bapis
  INCLUDE MMCP6FC0.                    "FORM-Routinen Buchstabe C
  INCLUDE MMCP6FD0.                    "FORM-Routinen Buchstabe D
  INCLUDE MMCP6FE0.                    "FORM-Routinen Buchstabe E
  INCLUDE MMCP6FF0.                    "FORM-Routinen Buchstabe F
  INCLUDE MMCP6FG0.                    "FORM-Routinen Buchstabe G
  INCLUDE MMCP6FI0.                    "FORM-Routinen Buchstabe I
  INCLUDE MMCP6FK0.                    "FORM-Routinen Buchstabe K
  INCLUDE MMCP6FL0.                    "FORM-Routinen Buchstabe L
  INCLUDE MMCP6FM0.                    "FORM-Routinen Buchstabe M
  INCLUDE MMCP6FN0.                    "FORM-Routinen Buchstabe N
  INCLUDE MMCP6FP0.                    "FORM-Routinen Buchstabe P
  INCLUDE MMCP6FR0.                    "FORM-Routinen Buchstabe R
  INCLUDE MMCP6FS0.                    "FORM-Routinen Buchstabe S
  INCLUDE MMCP6FT0.                    "FORM-Routinen Buchstabe T
  INCLUDE MMCP6FU0.                    "FORM-Routinen Buchstabe U
  INCLUDE MMCP6FV0.                    "FORM-Routinen Buchstabe V
  INCLUDE MMCP6FW0.                    "FORM-Routinen Buchstabe W
  INCLUDE MMCP6FZ0.                    "FORM-Routinen Buchstabe Z

  INCLUDE MMCP6FKA.                    "Kapaplanung
* INCLUDE MMCP6FKO.                    "Kapaplanung
  INCLUDE MMCP6FGP.                    "Grobplanungsprofile
  INCLUDE MMCP6FER.                    "Ereignisse
  INCLUDE MMCP6FPR.                    "Prognose ab 4.0

* Anfang Reparatur OTB
  INCLUDE MMCP6WWS.                    "FORM-Routinen für OTB
* Ende Reparatur OTB
  INCLUDE MMCP6FKP.
  INCLUDE MMCP6MRP.    "Formroutines für Dispoliste

*---------------------------------------------------------------------*
* additional Module to replace original Module EXIT_COMMAND
* because original Module EXIT_COMMAND restrict for standard SAP Tcode
* See SAPMMCP6 Screen 160
*---------------------------------------------------------------------*
  MODULE EXIT_COM.
*   Retten OK-Code
*{   REPLACE        P01K910653                                        1
*\    MOVE OK-CODE TO SAV_OK-CODE.
    MOVE OK-CODE TO SAV_OK_CODE.      "SOH: Shell SCI Adjustment 20240227 KRS
*}   REPLACE
    CLEAR OK-CODE.

*   Exitcodepruefung
    CASE SY-DYNNR.
      WHEN '0160'.
        PERFORM EXIT_0160.
    ENDCASE.
  ENDMODULE.
