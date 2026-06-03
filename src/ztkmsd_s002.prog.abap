*&----------------------------------------------------------------------
*&
*&----------------------------------------------------------------------
*& RICEF ID             : ESD-01
*& Program Name         : ZTKMSD_E001
*& Functional Designer  :
*& ABAP Developer       : Sukardi
*& Creation Date        : 15.04.2018
*& SAP Release          : ECC6.0
*& Description          :
*&
*&---------------------------------------------------------------------*
*& M O D I F I C A T I O N   L O G
*&---------------------------------------------------------------------*
*& Log  TR          FUNCTIONAL  ABAPER    DESCRIPTION
*&---------------------------------------------------------------------*
*& 001
*&
*&---------------------------------------------------------------------*
REPORT  ztkmsd_s002 NO STANDARD PAGE HEADING
                     LINE-SIZE 255.

*------------------common TOP includes for the program----------------*

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*


START-OF-SELECTION.

  CALL SCREEN 100.


END-OF-SELECTION.

*------------------common Routine includes for the program----------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status OUTPUT.
      SET PF-STATUS 'PF_0100' .
ENDMODULE.                 " STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  VALIDATE_DATA  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE validate_data OUTPUT.
ENDMODULE.                 " VALIDATE_DATA  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command INPUT.
  CASE sy-ucomm.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'CHECK'.
      CLEAR sy-ucomm.
      SUBMIT ztkmsd_e006  VIA SELECTION-SCREEN
          AND RETURN .
      set screen  100..

    WHEN 'START'.
      CLEAR sy-ucomm.
      SUBMIT ztkmsd_e007  VIA SELECTION-SCREEN
          AND RETURN .
      set screen  100.
    WHEN 'END'.
      CLEAR sy-ucomm.
      SUBMIT ztkmsd_e008  VIA SELECTION-SCREEN
          AND RETURN .
      set screen  100..
    WHEN 'REPO'.
      CLEAR sy-ucomm.
      SUBMIT ztkmsd_R004  VIA SELECTION-SCREEN
          AND RETURN .
      set screen  100..

    WHEN 'R01'.
      SUBMIT ztkmsd_r013  VIA SELECTION-SCREEN
          AND RETURN .
    WHEN 'R02'.
      SUBMIT ztkmsd_r014  VIA SELECTION-SCREEN
          AND RETURN .
    WHEN 'R03'.
      SUBMIT ztkmsd_r015  VIA SELECTION-SCREEN
          AND RETURN .


    WHEN space.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND  INPUT
